require 'rails_helper'

feature "User blocking", js: true do
  fixtures :users, :blockages

  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'on a profile page' do

    scenario 'button blocks a user' do
      subject = users(:howard)
      visit "/#{subject.username}"
      db_count = user.blocking.count
      accept_confirm { find('.r_block').click }
      expect(page).to have_link("Blocking #{subject.first_name}")
      expect(user.blocking.count).to eq(db_count + 1)
    end

    scenario 'button unblocks a user' do
      subject = users(:jon)
      visit "/#{subject.username}"
      db_count = user.blocking.count
      accept_confirm { click_link("Blocking #{subject.first_name}") }
      expect(page).to have_selector('.r_block')
      expect(user.blocking.count).to eq(db_count - 1)
    end
  end
end
