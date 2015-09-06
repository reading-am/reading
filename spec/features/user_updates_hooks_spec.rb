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
    details_win = window_opened_by_js { click_link('Details') }
    expect(windows.length).to eq(2)

    within_window(details_win) do
      expect(current_path).to start_with('/footnotes')
      current_window.close
    end
  end

  scenario 'submit button creates a new hook' do
    visit url

    dom_count = all('.hook').count
    db_count = user.hooks.count

    click_button('Thanks!')

    expect(all('.hook').count).to eq dom_count + 1
    expect(user.hooks.reload.count).to eq db_count + 1
  end

  scenario 'delete button deletes a hook' do
    visit url

    dom_count = all('.hook').count
    db_count = user.hooks.count

    first('.hook').hover
    accept_confirm { click_link('Delete') }

    expect(all('.hook').count).to eq dom_count - 1
    expect(user.hooks.reload.count).to eq db_count - 1
  end

  scenario 'adds a new authentication when creating a hook' do
    whitelist 'https://api.twitter.com/oauth/*'

    # Remove twitter auth so we can add it back
    user.authorizations.where(provider: 'twitter').destroy_all

    visit url

    dom_count = all('.hook').count
    auth_count = user.authorizations.count
    hook_count = user.hooks.count

    select 'Twitter', from: 'hook_provider'
    select '+ connect new', from: 'hook_params_account'
    twitter_win = window_opened_by_js { click_button('Thanks!') }

    expect(windows.length).to eq(2)
    expect(page).to have_selector '#loading'

    within_window(twitter_win) do
      expect(current_url).to start_with('https://api.twitter.com/oauth/authorize')
      fill_in 'Username or email', with: ENV['TWITTER_TEST_ACCOUNT_EMAIL']
      fill_in 'Password', with: ENV['TWITTER_TEST_ACCOUNT_PASS']
      click_button 'Authorize app'
    end

    expect(page).not_to have_selector('#loading'), "Page didn't reload after auth was added"
    expect(windows.length).to eq(1)
    expect(user.authorizations.reload.count).to eq(auth_count + 1), "A new authorization wasn't added"
    expect(all('.hook').count).to eq dom_count + 1
    expect(user.hooks.reload.count).to eq hook_count + 1
  end
end
