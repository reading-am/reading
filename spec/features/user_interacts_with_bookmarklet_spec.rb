require 'rails_helper'

feature "User's bookmarklet", js: true do
  include UsersHelper
  fixtures :users, :domains, :pages

  let(:url) { 'http://www.example.com' }
  let(:user) { users(:greg) }

  def trigger_bookmarklet_for(user)
    # Array access removes 'javascript:' prefix
    execute_script bookmarklet_url(user)[11..-1]
    # Causes the test to wait for the bookmarklet to load
    expect(page).to have_selector('#r_am'), "Initial bookmarklet load failed"
    # Causes the test to wait for the post to be created
    expect(page).to have_selector('.r_comments_with_input'), "UI didn't reflect that a post was created"
  end

  scenario 'loads and posts from a site' do
    db_count = user.posts.count
    visit url

    trigger_bookmarklet_for user
    expect(user.posts.reload.count).to eq(db_count + 1), "A post wasn't added to the database"
  end

  scenario 'loads and posts from a site' do
    visit url

    trigger_bookmarklet_for user
    post = user.posts.last
    expect(post.yn).to eq(nil)

    within('#r_am') do
      click_link('Yep')
      wait_for_js
    end

    expect(post.reload.yn).to eq(true), "Post's yep nope wasn't updated"
  end
end
