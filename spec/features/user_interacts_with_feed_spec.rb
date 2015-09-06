require 'rails_helper'

feature "User's logged in feed", js: true do
  fixtures :users, :relationships, :domains, :pages, :posts, :comments

  let(:url) { '/' }
  let(:user) { users(:greg) }

  before(:each) do
    login_as user, scope: :user
  end

  scenario 'displays posts' do
    visit url
    expect(page).to have_selector('.page_row')
  end

  scenario 'progressively renders posts while scrolling' do
    visit url
    dom_count = all('.page_row').count
    expect(dom_count).to be > 0, 'No page rows were found'
    scroll_to_bottom
    expect(all('.page_row').count).to be > dom_count, "Additional page rows weren't added after scroll"
  end

  scenario 'renders more posts when the end of the page is reached (infinite scroll)' do
    limit = 3
    visit "/#{user.username}/list?limit=#{limit}"

    dom_count = all('.r_subpost').count
    expect(dom_count).to eq(limit), 'Not enough posts were found'
    scroll_to_bottom
    expect(all('.r_subpost').count).to be > limit, "Additional page rows weren't added after scroll"
  end

  describe 'header' do

    scenario 'clicking the Post a Link button allows a new post to be created' do
      visit url
      db_count = Post.count
      dom_count = all('.page_row').count

      click_link 'Post a Link'
      wait_for_js
      fill_in "Enter the url you'd like to post", with: 'http://example.com'
      click_button 'Add Post'
      wait_for_js

      expect(page).not_to have_selector('#new_post_row'), "The new post input wasn't hidden"
      expect(all('.page_row').count).to eq(dom_count + 1), "A new page wasn't added to the DOM"
      expect(Post.count).to eq(db_count + 1), "A new post wasn't added to the database"
    end

    scenario 'selecting a medium filters the posts' do
      visit url

      dom_count = all('.page_row').count
      expect(dom_count).to be > 0, "No posts were rendered"

      select 'images', from: 'medium'
      wait_for_js

      expect(all('.page_row').count).to be > 0, "No posts were rendered"
      expect(all('.page_row').count).to be < dom_count, "A new page wasn't added to the DOM"
    end

    scenario 'selecting yep or nope filters the posts' do
      visit url

      dom_count = all('.page_row').count
      expect(dom_count).to be > 0, "No posts were rendered"

      select 'yeps', from: 'yn'
      wait_for_js

      expect(all('.page_row').count).to be > 0, "No posts were rendered"
      expect(all('.page_row').count).to be < dom_count, "A new page wasn't added to the DOM"
    end
  end

  describe 'page row' do

    scenario 'clicking a post icon toggles between comments and posts' do
      visit url
      scroll_to_bottom
      within(first_parent_with_class_containing('page_row', first('.has_comments'))) do
        button = find('.comments_icon')
        count = button.text
        button.click
        wait_for_js
        expect(find('.r_comments')).to have_selector('.r_comment', count: count)

        button = find('.posts_icon')
        count = button.text
        button.click
        wait_for_js
        expect(find('.r_subposts')).to have_selector('.r_subpost', count: count)
      end
    end

    describe 'page' do
      scenario 'title posts the page and redirects to the page source when clicked' do
        db_count = user.posts.count

        visit url
        scroll_to_bottom

        dest_win = window_opened_by_js do
          within(first_parent_with_class_containing('page_row', first('.pa_create'))) do
            find('.r_title a').click
          end
        end

        within_window(dest_win) do
          # Causes test to wait for redirect before checking host 
          expect(page).not_to have_content('Loading')
          expect(URI.parse(current_url).host).not_to eq(Capybara.current_session.server.host)
          current_window.close
        end

        expect(user.posts.count).to eq(db_count + 1), "Post wasn't added to the database"
      end

      scenario 'title redirects logged out visitor to the page source when clicked' do
        logout(:user)
        visit url

        dest_win = window_opened_by_js { first('.r_title a').click }
        within_window(dest_win) do
          # Causes test to wait for redirect before checking host 
          expect(page).not_to have_content('Loading')
          expect(URI.parse(current_url).host).not_to eq(Capybara.current_session.server.host)
          current_window.close
        end
      end

      scenario 'domain visits the domain endpoint when clicked' do
        visit url
        domain = first('.r_page_hostname')
        name = domain.text # must cache since element will disappear after click
        domain.click

        # we hide www when displaying the domain name if it exists
        expect(["/domains/#{name}", "/domains/www.#{name}"]).to include(current_path)
      end

      scenario 'id visits the page endpoint when clicked' do
        visit url
        domain = first('.r_page_hostname').text
        page = first('.r_page_permalink')
        id = page.text # must cache since element will disappear after click
        page.click

        # we hide www when displaying the domain name if it exists
        expect(["/domains/#{domain}/pages/#{id}", "/domains/www.#{domain}/pages/#{id}"]).to include(current_path)
      end
    end

    describe 'post' do

      scenario 'is created when clicking a post button' do
        db_count = user.posts.count

        visit url
        scroll_to_bottom

        within(first_parent_with_class_containing('page_row', first('.pa_create'))) do
          dom_count = all('.r_subpost').count
          find('.pa_create').click
          wait_for_js
          expect(page).to have_selector('.pa_destroy'), "Post button didn't change state"
          expect(page).to have_selector('.r_subpost', count: dom_count + 1)
        end

        expect(user.posts.count).to eq(db_count + 1), "Post wasn't added to the database"
      end

      scenario 'is deleted when clicking a post delete button' do
        db_count = user.posts.count

        visit url
        scroll_to_bottom

        row = nil
        all('.pa_destroy').each do |el|
          row = first_parent_with_class_containing('page_row', el)
          if row.all('.r_subpost').count > 1
            break
          else
            row = nil
          end
        end

        expect(row).to be_truthy, "A page with more than one subpost wasn't found"

        within(row) do
          dom_count = all('.r_subpost').count
          accept_confirm { find('.pa_destroy').click }
          wait_for_js
          expect(page).to have_selector('.pa_create'), "Post button didn't change state"
          expect(page).to have_selector('.r_subpost', count: dom_count - 1)
        end

        expect(user.posts.count).to eq(db_count - 1), "Post wasn't removed from the database"
      end

      scenario 'delete button removes the page from the DOM when deleting the last post' do
        db_count = user.posts.count

        visit url
        scroll_to_bottom
        dom_count = all('.page_row').count

        row = nil
        all('.pa_destroy').each do |el|
          row = first_parent_with_class_containing('page_row', el)
          break if row.all('.r_subpost').count == 1
        end

        expect(row).to be_truthy, "A page with only one subpost wasn't found"

        within(row) do
          accept_confirm { find('.pa_destroy').click }
          wait_for_js
        end

        expect(all('.page_row').count).to eq(dom_count - 1), "Page wasn't removed from the DOM"
        expect(user.posts.count).to eq(db_count - 1), "Post wasn't removed from the database"
      end

      it_behaves_like 'a yep nope button', :yep
      it_behaves_like 'a yep nope button', :nope

      it_behaves_like 'is shareable' do
        let(:share_link) do
          visit url
          find_link('Share', match: :first)
        end
      end
    end

    describe 'subposts' do

      before(:each) do
        visit url
      end

      scenario 'are rendered on initial load' do
        row = first('.page_row')
        expect(row).to have_selector('.r_subposts')
        expect(row.all('.r_post').count).to be > 0
      end

      it_behaves_like 'visits user' do
        let(:user_link) { first('.r_post .r_name') }
      end
    end

    describe 'comments' do

      before(:each) do
        # Remove other posts just to make it easier
        Post.where.not(id: user.comments.first.post.id).destroy_all

        visit url
        within(first_parent_with_class_containing('page_row', first('.has_comments'))) do
          find('.comments_icon').click
          wait_for_js
        end
      end

      it_behaves_like 'comment input'

      it_behaves_like 'comment delete button'

      it_behaves_like 'comment permalink button'

      it_behaves_like 'is shareable' do
        let(:share_link) do
          body = first('.r_comment_body')
          comment = first_parent_with_class_containing('r_comment', body)
          comment.hover
          return comment.find_link('Share')
        end
      end

      it_behaves_like 'visits user' do
        let(:user_link) { first('.r_comment .r_name') }
      end
    end
  end
end
