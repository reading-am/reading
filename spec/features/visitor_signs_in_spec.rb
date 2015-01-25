require 'rails_helper'

feature 'Signing in' do
  fixtures :users

  scenario 'Signing in with correct username credentials' do
    user = users(:greg)

    visit '/sign_in'
    within('#signin_form_wrapper') do
      fill_in 'Username or email', with: user.username
      fill_in 'Password', with: 'testingtesting'
    end
    click_button 'Sign in'
    expect(current_path).to eq("/#{user.username}/list")
  end

  scenario 'Signing in with correct email credentials' do
    user = users(:greg)

    visit '/sign_in'
    within('#signin_form_wrapper') do
      fill_in 'Username or email', with: user.email
      fill_in 'Password', with: 'testingtesting'
    end
    click_button 'Sign in'
    expect(current_path).to eq("/#{user.username}/list")
  end

  scenario 'Signing in with incorrect credentials' do
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
end
