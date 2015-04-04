require 'rails_helper'

feature 'User authentication', js: true do
  fixtures :users

  let(:url) { '/sign_in' }
  let(:user) { users(:greg) }

  describe 'signing in' do

    scenario 'with correct username credentials' do
      visit url
      within('#signin_form_wrapper') do
        fill_in 'Username or email', with: user.username
        fill_in 'Password', with: 'testingtesting'
      end
      click_button 'Sign in'
      expect(current_path).to eq("/#{user.username}/list")
    end

    scenario 'with correct email credentials' do
      visit url
      within('#signin_form_wrapper') do
        fill_in 'Username or email', with: user.email
        fill_in 'Password', with: 'testingtesting'
      end
      click_button 'Sign in'
      expect(current_path).to eq("/#{user.username}/list")
    end

    scenario 'with incorrect credentials' do
      visit url
      within('#signin_form_wrapper') do
        fill_in 'Username or email', with: user.username
        fill_in 'Password', with: 'incorrectpassword'
      end
      click_button 'Sign in'
      expect(current_path).to eq(url)
      expect(page).to have_content 'Invalid'
    end

    scenario 'with Twitter' do
      visit '/'

      click_link 't Twitter'
      expect(windows.length).to eq(2)

      within_window(windows.last) do
        expect(current_url).to start_with('https://api.twitter.com/oauth/authorize')
        current_window.close
      end
    end

    scenario 'with Facebook' do
      visit '/'

      click_link 'f Facebook'
      expect(windows.length).to eq(2)

      within_window(windows.last) do
        expect(current_url).to start_with('https://www.facebook.com/dialog/oauth')
        current_window.close
      end
    end
  end

  describe 'signing out' do

    scenario 'from settings page' do
      login_as user, scope: :user
      visit '/settings/info'
      click_link 'Sign Out'
      page.driver.browser.switch_to.alert.accept
      expect(current_path).to eq('/')
      expect(page).to have_content('Sign up or in')
    end
  end
end
