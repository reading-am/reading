require 'rails_helper'

feature "User's feed", js: true do
  fixtures :users, :domains, :pages, :posts, :comments

  scenario 'visiting displays posts' do
    login_as users(:greg), scope: :user

    visit '/'
    expect(page).to have_selector('.page_row')
  end

  scenario 'clicking a post icon toggles between comments and posts' do
    login_as users(:greg), scope: :user

    visit '/'
    row = first('.has_comments').find(:xpath, 'ancestor::*[contains(concat(" ",normalize-space(@class)," ")," page_row ")]')
    within(row) do
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
    row = first('.has_comments').find(:xpath, 'ancestor::*[contains(concat(" ",normalize-space(@class)," ")," page_row ")]')
    within(row) do
      body = 'This is a comment'
      find('.comments_icon').click
      find_field('Add a comment')
        .send_keys(body)
        .send_keys(:return)
      wait_for_js

      expect(first('.r_comment')).to have_text(body), "Comment wasn't added to the DOM"
    end

    expect(Comment.count).to eq(count + 1), "Comment wasn't added to the database"
  end
end
