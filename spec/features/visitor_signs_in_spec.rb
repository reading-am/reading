require 'rails_helper'

feature 'Signing in', js: true do
  fixtures :users

  scenario 'with correct username credentials' do
    user = users(:greg)

    visit '/sign_in'
    within('#signin_form_wrapper') do
      fill_in 'Username or email', with: user.username
      fill_in 'Password', with: 'testingtesting'
    end
    click_button 'Sign in'
    expect(current_path).to eq("/#{user.username}/list")
  end

  scenario 'with correct email credentials' do
    user = users(:greg)

    visit '/sign_in'
    within('#signin_form_wrapper') do
      fill_in 'Username or email', with: user.email
      fill_in 'Password', with: 'testingtesting'
    end
    click_button 'Sign in'
    expect(current_path).to eq("/#{user.username}/list")
  end

  scenario 'with incorrect credentials' do
    user = users(:greg)

    visit '/sign_in'
    within('#signin_form_wrapper') do
      fill_in 'Username or email', with: user.username
      fill_in 'Password', with: 'incorrectpassword'
    end
    click_button 'Sign in'
    expect(current_path).to eq('/sign_in')
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
