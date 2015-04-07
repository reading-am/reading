require 'rails_helper'

feature "User profile page", js: true do
  fixtures :users, :relationships, :blockages

  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  describe 'blocking' do

    scenario 'button blocks a user' do
      subject = users(:howard)
      visit "/#{subject.username}"
      db_count = user.blocking.count
      find('.r_block').click
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_link("Blocking #{subject.first_name}")
      expect(user.blocking.count).to eq(db_count + 1)
    end

    scenario 'button unblocks a user' do
      subject = users(:jon)
      visit "/#{subject.username}"
      db_count = user.blocking.count
      click_link("Blocking #{subject.first_name}")
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_selector('.r_block')
      expect(user.blocking.count).to eq(db_count - 1)
    end
  end
end
