require 'rails_helper'

feature "User's settings", js: true do
  fixtures :users, :authorizations

  let(:url) { '/settings/info' }

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

    scenario 'updates user info' do
      user = users(:greg)
      login_as user, scope: :user
      old_name = user.name
      new_name = 'A new name'
      expect(new_name).not_to eq(old_name)

      visit url
      expect(page).to have_selector("input[value='#{old_name}']")
      fill_in 'Name', with: new_name
      click_button 'Update Me'

      expect(page).to have_selector("input[value='#{new_name}']")
      expect(user.reload.name).to eq(new_name), "The name wasn't update in the database"
    end

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
