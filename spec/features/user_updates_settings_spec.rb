require 'rails_helper'

feature "User's settings", js: true do
  fixtures :users

  describe 'delete button' do
    let(:url) { '/settings/info' }
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
end
