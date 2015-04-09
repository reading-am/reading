require 'rails_helper'

feature 'User admins apps', js: true do
  fixtures :users, :oauth_applications

  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'as a developer' do

    before(:each) do
      visit '/settings/apps/dev'
    end

    scenario 'creates an app' do
      db_count = user.oauth_owner_apps.count
      dom_count = all('.r_oauth_app').count

      click_link '[+] Create a new app'
      fill_in 'Name', with: 'My New App'
      fill_in 'Callback URI', with: 'https://example.com'
      click_button 'Create App'

      expect(all('.r_oauth_app').count).to eq(dom_count + 1)
      expect(user.oauth_owner_apps.count).to eq(db_count + 1)
    end

    scenario 'edits an app' do
      app = Doorkeeper::Application.find_by_uid(first('.r_key code').text)
      old_val = first('.r_name').text
      new_val = 'A New App Name'
      expect(new_val).not_to eq(old_val)

      first('.btn', text: /Edit/).click
      fill_in 'Name', with: new_val
      click_button 'Save'

      expect(page).not_to have_text(old_val)
      expect(page).to have_text(new_val)
      expect(app.reload.name).to eq(new_val)
    end

    scenario 'deletes an app' do
      db_count = user.oauth_owner_apps.count
      dom_count = all('.r_oauth_app').count

      first('.btn', text: /Edit/).click
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      wait_for_js

      expect(all('.r_oauth_app').count).to eq(dom_count - 1)
      expect(user.oauth_owner_apps.count).to eq(db_count - 1)
    end
  end

  describe 'as a consumer' do
    
  end
end
