require 'rails_helper'

feature 'User authentication', js: true do
  fixtures :users, :authorizations, :pages, :posts

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
      whitelist 'https://api.twitter.com/oauth/*'
      visit '/'

      click_link 't Twitter'
      expect(windows.length).to eq(2)
      expect(page).to have_selector '#loading'

      within_window(windows.last) do
        expect(current_url).to start_with('https://api.twitter.com/oauth/authorize')
        fill_in 'Username or email', with: ENV['TWITTER_TEST_ACCOUNT_EMAIL']
        fill_in 'Password', with: ENV['TWITTER_TEST_ACCOUNT_PASS']
        click_button 'Authorize app'
      end

      expect(page).not_to have_selector('#loading'), "Page didn't reload after auth was added"
      expect(windows.length).to eq(1)
      expect(current_path).to eq("/#{user.username}/list")
    end

    scenario 'with Facebook' do
      whitelist '*.facebook.*'
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
      accept_confirm { click_link 'Sign Out' }
      expect(current_path).to eq('/')
      expect(page).to have_content('Sign up or in')
    end
  end
end
