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

  shared_context 'a yep nope button' do |yn|
    scenario "clicking a #{yn} button toggles #{yn} on a post" do
      visit url

      trigger_bookmarklet_for user
      post = user.posts.last
      expect(post.yn).to eq(nil)

      within('#r_am') do
        click_link(yn.to_s.capitalize)
        wait_for_js
      end

      expect(post.reload.yn).to eq(yn == :yep), "Post's yep nope wasn't updated"
    end
  end

  it_behaves_like 'a yep nope button', :yep
  it_behaves_like 'a yep nope button', :nope
end
