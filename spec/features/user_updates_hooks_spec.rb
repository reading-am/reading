require 'rails_helper'

feature "User's hooks", js: true do
  fixtures :users, :authorizations, :hooks

  let(:url) { '/settings/hooks' }
  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  scenario 'renders the hooks form' do
    visit url
    expect(page).to have_selector('#hook_events')
    expect(page).to have_selector('#hook_provider')
  end

  scenario 'lists existing hooks' do
    visit url
    expect(all('.hook').count).to eq user.hooks.count
  end

  scenario 'detail button opens window with explanation' do
    visit url
    click_link('Details')
    expect(windows.length).to eq(2)

    within_window(windows.last) do
      expect(current_path).to start_with('/footnotes')
      current_window.close
    end
  end
end
