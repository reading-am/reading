require 'rails_helper'

feature 'User registers for an account', js: true do
  fixtures :users, :pages, :posts

  let(:user) { users(:greg) }

  scenario 'via email' do
    db_count = User.count
    name = 'John Smith'
    email = 'test@example.com'
    username = 'test_user'

    visit '/', wait: false
    find('.provider.email').click

    within(find('#signup_form_wrapper')) do
      fill_in 'Full name', with: name
      fill_in 'Email', with: email
      fill_in 'Password', with: 'testingtesting'
      click_button 'Make me a Reader!'
    end

    fill_in 'Username', with: username
    click_button 'All done'

    expect(page).to have_selector('#blank_slate')
    expect(User.count).to eq(db_count + 1)

    new_user = User.last
    expect(new_user.name).to eq(name)
    expect(new_user.email).to eq(email)
    expect(new_user.username).to eq(username)
  end

  scenario 'via Twitter' do
    whitelist 'https://api.twitter.com/oauth/*'

    db_count = User.count
    name = 'Reading Test'
    email = 'test@example.com'
    username = 'reading_test'

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

    fill_in 'Email', with: email
    fill_in 'Password', with: 'testingtesting'
    fill_in 'Password Confirm', with: 'testingtesting'
    click_button 'All done'

    expect(page).to have_selector('#blank_slate')
    expect(User.count).to eq(db_count + 1)

    new_user = User.last
    expect(new_user.name).to eq(name)
    expect(new_user.email).to eq(email)
    expect(new_user.username).to eq(username)
  end
end
