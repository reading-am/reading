require 'rails_helper'

feature "User's bookmarklet", js: true do
  include UsersHelper
  fixtures :users, :domains, :pages, :comments

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

  scenario "clicking a share button brings up a share sheet" do
    visit url

    trigger_bookmarklet_for user
    click_link('Share', match: :first)
    expect(page).to have_selector('#r_share_menu'), "Share menu wasn't displayed"

    click_link('Twitter')
    expect(windows.length).to eq(2)

    within_window(windows.last) do
      expect(current_url).to start_with('https://twitter.com/intent')
      current_window.close
    end
  end

  describe 'comments' do

    before(:each) do
      visit url
      trigger_bookmarklet_for user
    end

    it_behaves_like 'comment input'

    it_behaves_like 'comment delete button'

    it_behaves_like 'comment permalink button'

    it_behaves_like 'is shareable' do
      let(:share_link) do
        comment = first('.r_comment')
        comment.hover
        return comment.find_link('Share')
      end
    end

    scenario 'visits user by navigating to user page upon click' do
      user_link = first('.r_comment .r_name')
      name = user_link.text
      user_link.click

      within_frame('r_user_overlay') do
        expect(current_path).to match(/\/[^\/]+/), "Path wasn't a root user path"
        expect(first('h1')).to have_text(name)
      end
    end
  end
end
