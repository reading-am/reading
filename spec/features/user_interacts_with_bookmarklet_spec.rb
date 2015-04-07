require 'rails_helper'

feature "User's bookmarklet", js: true do
  include UsersHelper
  fixtures :users, :domains, :pages, :posts, :comments

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

  before(:each) do |example|
    unless example.metadata[:skip_before]
      visit url
      trigger_bookmarklet_for user
    end
  end

  scenario 'loads and posts from a site', :skip_before do
    db_count = user.posts.count
    visit url
    trigger_bookmarklet_for user
    expect(user.posts.reload.count).to eq(db_count + 1), "A post wasn't added to the database"
  end

  scenario 'is closed when the close button is clicked', :skip_before do
    visit url
    trigger_bookmarklet_for user
    click_link('r_close')
    expect(page).not_to have_selector('#r_am'), "Bookmarklet wasn't removed from the page"
  end

  describe 'post' do

    shared_context 'a yep nope button' do |yn|
      scenario "clicking a #{yn} button toggles #{yn} on a post" do
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

    it_behaves_like 'is shareable' do
      let(:share_link) { find_link('Share', match: :first) }
    end
  end

  describe 'subposts' do

    scenario 'are rendered on initial load' do
      expect(page).to have_selector('#r_readers')
      expect(page.all('.r_post').count).to be > 0
    end

    it_behaves_like 'visits user', :iframe do
      let(:user_link) { first('.r_post .r_name') }
    end
  end

  describe 'comments' do

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

    it_behaves_like 'visits user', :iframe do
      let(:user_link) { first('.r_comment .r_name') }
    end
  end
end
