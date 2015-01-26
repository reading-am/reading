require 'rails_helper'

feature "User's feed" do
  fixtures :users, :domains, :pages, :posts

  scenario 'Visiting displays posts' do
    user = users(:greg)
    login_as user, scope: :user

    visit '/'
    expect(page).to have_selector('.page_row', count: 2)
  end
end
