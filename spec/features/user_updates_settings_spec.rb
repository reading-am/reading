require 'rails_helper'

feature "User's settings", js: true do
  fixtures :users, :authorizations

  let(:url) { '/settings/info' }
  let(:password) { 'testingtesting' }

  describe 'delete button' do
    let(:button_text) { 'I respectfully request to be destroyed.' }

    scenario 'clicking counts down and then deletes user' do
      login_as users(:greg), scope: :user
      db_count = User.count
      visit url

      click_link button_text
      page.driver.browser.switch_to.alert.accept

      # waits for the count down
      (0..5).to_a.reverse.each { |i| find_link("Self destruct in #{i} (click to cancel)") }
      sleep 1 # because the last number in the count down will pause for 1 second

      assert_equal '/sign_in', current_path
      expect(User.count).to eq(db_count - 1), "User wasn't deleted from the database"
    end

    scenario 'clicking after count down begins cancels delete' do
      login_as users(:greg), scope: :user
      db_count = User.count
      visit url

      click_link button_text
      page.driver.browser.switch_to.alert.accept
      click_link("Self destruct in 5 (click to cancel)")

      expect(page).to have_link(button_text)
      expect(User.count).to eq(db_count), "User was deleted from the database"
    end
  end

  describe 'info form' do

    scenario 'updates user avatar' do
      user = users(:greg)
      login_as user, scope: :user
      old_file = user.avatar_file_name

      visit url
      attach_file 'user_avatar', Rails.root.join('spec/fixtures/test.jpg')
      click_button 'Update Me'

      expect(page).to have_selector('#avatar img')
      expect(user.reload.avatar_file_name).not_to eq(old_file)
    end

    scenario 'updates user info without password' do
      user = users(:greg)
      login_as user, scope: :user
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
      user = users(:greg)
      login_as user, scope: :user
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
      user = users(:greg)
      login_as user, scope: :user
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

      expect(user.reload.encrypted_password).not_to eq(old_val), "The password wasn't updated in the database"
    end
  end

  scenario 'connection disconnect button removes connection' do
    user = users(:greg)
    login_as user, scope: :user

    visit url
    db_count = Authorization.count
    dom_count = all('.authorization').count

    first('.authorization').hover
    click_link('Disconnect')
    page.driver.browser.switch_to.alert.accept

    expect(all('.authorization').count).to eq(dom_count - 1), "Authorization wasn't removed from the DOM"
    expect(Authorization.count).to eq(db_count - 1), "Authorization wasn't deleted from the database"
  end

  scenario 'connection cannot be removed if it is the only one' do
    user = users(:greg)
    auth = user.authorizations.last
    user.authorizations.each { |a| a.destroy unless a == auth }
    user.authorizations.reload

    login_as user, scope: :user

    visit url
    find('.authorization').hover
    expect(page).not_to have_link('Disconnect')
  end
end
