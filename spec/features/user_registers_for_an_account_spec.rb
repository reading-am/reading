require 'rails_helper'

feature 'User registers for an account', js: true do
  fixtures :users

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
end
