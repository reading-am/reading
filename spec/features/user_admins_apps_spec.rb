require 'rails_helper'

feature 'User admins apps', js: true do
  fixtures :users, :oauth_applications, :oauth_access_tokens

  let(:user) { users(:greg) }
  let(:app) { oauth_applications(:ios) }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'as a developer' do

    before(:each) do
      visit '/settings/apps/dev'
      # wait for elements to render
      expect(page).not_to have_selector('.r_loading')
    end

    scenario 'creates an app' do
      db_count = user.oauth_owner_apps.count
      dom_count = all('.r_oauth_app').count

      click_link '[+] Create a new app'
      fill_in 'Name', with: 'My New App'
      fill_in 'Callback URI', with: 'https://example.com'
      click_button 'Create App'
      wait_for_js

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
      wait_for_js

      expect(page).not_to have_text(old_val)
      expect(page).to have_text(new_val)
      expect(app.reload.name).to eq(new_val)
    end

    scenario 'deletes an app' do
      db_count = user.oauth_owner_apps.count
      dom_count = all('.r_oauth_app').count

      first('.btn', text: /Edit/).click
      accept_confirm { click_link 'Delete' }
      wait_for_js

      expect(all('.r_oauth_app').count).to eq(dom_count - 1)
      expect(user.oauth_owner_apps.count).to eq(db_count - 1)
    end
  end

  describe 'as a consumer' do

    scenario 'creates an oauth token' do
      user.oauth_access_tokens.destroy_all
      db_count = user.oauth_access_tokens.count

      visit "/oauth/authorize?client_id=#{app.uid}&redirect_uri=#{app.redirect_uri}&response_type=code", wait: false
      click_button 'Authorize'
      code = find('#authorization_code').text

      Typhoeus.post "#{ROOT_URL}/oauth/token", body: { grant_type: 'authorization_code',
                                                       client_id: app.uid,
                                                       client_secret: app.secret,
                                                       code: code,
                                                       redirect_uri: app.redirect_uri }

      expect(user.oauth_access_tokens.count).to eq(db_count + 1)

      visit '/settings/apps'
      expect(page).to have_text(app.name)
    end

    scenario 'revokes an oauth token' do
      visit '/settings/apps'
      expect(page).not_to have_selector('.r_loading')

      db_count = user.active_oauth_access_tokens.count
      dom_count = all('.r_oauth_access_token').count

      accept_confirm { first('.btn', text: /Revoke Access/).click }
      wait_for_js

      expect(all('.r_oauth_access_token').count).to eq(dom_count - 1)
      expect(user.active_oauth_access_tokens.count).to eq(db_count - 1)
    end
  end
end
