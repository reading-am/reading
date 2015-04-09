require 'rails_helper'

feature "User following", js: true do
  fixtures :users, :relationships

  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'on a profile page' do

    scenario 'the button follows a user' do
      subject = users(:howard)
      visit "/#{subject.username}"
      db_count = user.following.count
      click_link("Follow #{subject.first_name}")
      expect(page).to have_link("Unfollow #{subject.first_name}")
      expect(user.following.count).to eq(db_count + 1)
    end

    scenario 'the button unfollows a user' do
      subject = users(:max)
      visit "/#{subject.username}"
      db_count = user.following.count
      click_link("Unfollow #{subject.first_name}")
      expect(page).to have_link("Follow #{subject.first_name}")
      expect(user.following.count).to eq(db_count - 1)
    end
  end

  describe 'in a user list' do

    scenario 'the button follows a user' do
      visit '/users/recommended'
      db_count = user.following.count

      button = first('.btn', text: /Follow/)
      user_el = first_parent_with_class_containing('r_user', button)

      button.click
      expect(user_el).to have_selector('.btn', text: /Unfollow/)
      expect(user.following.count).to eq(db_count + 1)
    end

    scenario 'the button unfollows a user', elasticsearch: true do
      User.__elasticsearch__.create_index! index: User.index_name
      User.import

      visit "/users/search?q=#{users(:max).first_name}"
      db_count = user.following.count

      button = first('.btn', text: /Unfollow/)
      user_el = first_parent_with_class_containing('r_user', button)

      button.click
      expect(user_el).to have_selector('.btn', text: /Follow/)
      expect(user.following.count).to eq(db_count - 1)
    end
  end
end
