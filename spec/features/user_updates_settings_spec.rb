require 'rails_helper'

feature "User's settings", js: true do
  fixtures :users, :authorizations

  let(:url) { '/settings/info' }
  let(:user) { users(:greg) }
  let(:password) { 'testingtesting' }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'delete button' do
    let(:button_text) { 'I respectfully request to be destroyed.' }

    scenario 'counts down after click and then deletes user' do
      db_count = User.count
      visit url

      accept_confirm { click_link button_text }

      # waits for the count down
      (0..5).to_a.reverse.each { |i| find_link("Self destruct in #{i} (click to cancel)") }
      sleep 1 # because the last number in the count down will pause for 1 second

      assert_equal '/', current_path
      expect(User.count).to eq(db_count - 1), "User wasn't deleted from the database"
    end

    scenario 'clicking after count down begins cancels delete' do
      db_count = User.count
      visit url

      accept_confirm { click_link button_text }
      click_link("Self destruct in 5 (click to cancel)")

      expect(page).to have_link(button_text)
      expect(User.count).to eq(db_count), "User was deleted from the database"
    end
  end

  describe 'info form' do

    scenario 'updates user avatar' do
      old_file = user.avatar_file_name

      visit url
      attach_file 'user_avatar', Rails.root.join('spec/fixtures/test.jpg')
      click_button 'Update Me'

      expect(page).to have_selector('#avatar img')
      expect(user.reload.avatar_file_name).not_to eq(old_file)
    end

    scenario 'updates user info without password' do
      old_val = user.name
      new_val = 'A new name'
      expect(new_val).not_to eq(old_val)

      visit url
      expect(page).to have_selector("input[value='#{old_val}']")
      fill_in 'Name', with: new_val
      click_button 'Update Me'

      expect(page).to have_selector("input[value='#{new_val}']")
      expect(user.reload.name).to eq(new_val), "The name wasn't update in the database"
    end

    scenario 'requires password to update email' do
      old_val = user.email
      new_val = 'new_email@example.com'
      expect(new_val).not_to eq(old_val)

      visit url
      expect(page).to have_selector("input[value='#{old_val}']")
      fill_in 'Email', with: new_val
      click_button 'Update Me'

      expect(page).to have_field("Current password")
      expect(find('#user_current_password_controls')).to have_content("can't be blank")

      fill_in 'Current password', with: password
      click_button 'Update Me'
      expect(page).to have_selector("input[value='#{new_val}']")
      expect(user.reload.email).to eq(new_val), "The email wasn't updated in the database"
    end

    scenario 'requires current password to update password' do
      old_val = user.encrypted_password
      new_val = 'this is a new password'

      visit url
      expect(page).not_to have_selector('#confirm_password_fields'), "Password confirmation fields weren't hidden by default"
      fill_in 'New Password', with: new_val
      expect(page).to have_selector('#confirm_password_fields'), "Password confirmation fields weren't shown after password input"
      fill_in 'Password confirmation', with: new_val
      click_button 'Update Me'

      expect(page).to have_field("Current password")
      expect(find('#user_current_password_controls')).to have_content("can't be blank")

      fill_in 'New Password', with: new_val
      fill_in 'Password confirmation', with: new_val
      fill_in 'Current password', with: password
      click_button 'Update Me'

      expect(page).to have_text('You updated your account successfully.')
      expect(user.reload.encrypted_password).not_to eq(old_val), "The password wasn't updated in the database"
    end
  end

  describe 'connections' do

    scenario 'are listed' do
      visit url
      expect(all('.authorization').count).to eq user.authorizations.count
    end

    scenario 'disconnect button removes connection' do
      visit url
      db_count = user.authorizations.count
      dom_count = all('.authorization').count

      first('.authorization').hover
      accept_confirm { click_link('Disconnect') }

      expect(all('.authorization').count).to eq(dom_count - 1), "Authorization wasn't removed from the DOM"
      expect(user.authorizations.reload.count).to eq(db_count - 1), "Authorization wasn't deleted from the database"
    end

    scenario 'cannot be removed if there is only one' do
      auth = user.authorizations.last
      user.authorizations.where.not(id: auth.id).delete_all
      user.authorizations.reload

      visit url
      find('.authorization').hover
      expect(page).not_to have_link('Disconnect')
    end
  end
end
