require 'rails_helper'

feature "User's feed", js: true do
  fixtures :users, :relationships, :domains, :pages, :posts, :comments

  def first_row_containing(selector)
    first(selector).find(:xpath, 'ancestor::*[contains(concat(" ",normalize-space(@class)," ")," page_row ")]')
  end

  scenario 'visiting displays posts' do
    login_as users(:greg), scope: :user

    visit '/'
    expect(page).to have_selector('.page_row')
  end

  scenario 'clicking a post icon toggles between comments and posts' do
    login_as users(:greg), scope: :user

    visit '/'
    scroll_to_bottom
    within(first_row_containing('.has_comments')) do
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

  scenario 'clicking a comment icon displays comments' do
    login_as users(:greg), scope: :user
    count = Comment.count

    visit '/'
    scroll_to_bottom
    within(first_row_containing('.has_comments')) do
      body = 'This is a comment'
      click_link('.comments_icon')
      find_field('Add a comment')
        .send_keys(body)
        .send_keys(:return)
      wait_for_js

      expect(first('.r_comment')).to have_text(body), "Comment wasn't added to the DOM"
    end

    expect(Comment.count).to eq(count + 1), "Comment wasn't added to the database"
  end

  scenario 'clicking a post button posts a page' do
    login_as users(:greg), scope: :user
    db_count = Post.count

    visit '/'
    scroll_to_bottom
    within(first_row_containing('.pa_create')) do
      dom_count = all('.r_subpost').count
      find('.pa_create').click
      wait_for_js
      expect(page).to have_selector('.pa_destroy'), "Post button didn't change state"
      expect(page).to have_selector('.r_subpost', count: dom_count + 1)
    end

    expect(Post.count).to eq(db_count + 1), "Post wasn't added to the database"
  end
end
