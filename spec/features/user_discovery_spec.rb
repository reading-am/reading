require 'rails_helper'

feature "User discovery page", js: true do
  fixtures :users, :authorizations

  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  scenario 'recommends popular users' do
    visit '/users/recommended'
    expect(all('.r_user').count).to be > 0
  end

  scenario 'finds users who are friends on other platforms'

  scenario 'allows users to be searched for', elasticsearch: true do
    User.__elasticsearch__.create_index! index: User.index_name
    User.import

    visit "/users/search?q=#{users(:max).first_name}"
    expect(page).to have_text(users(:max).username)
  end
end
