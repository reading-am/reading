require 'rails_helper'

feature "User's feed", js: true do
  fixtures :users, :relationships, :domains, :pages, :posts, :comments

  def first_row_containing(selector)
    el = selector.is_a?(Capybara::Node::Element) ? selector : first(selector)
    el.find(:xpath, 'ancestor::*[contains(concat(" ",normalize-space(@class)," ")," page_row ")]')
  end

  scenario 'visiting displays posts' do
    login_as users(:greg), scope: :user

    visit '/'
    expect(page).to have_selector('.page_row')
  end

  scenario 'scrolling progressively renders posts' do
    login_as users(:greg), scope: :user

    visit '/'
    dom_count = all('.page_row').count
    expect(dom_count).to be > 0, 'No page rows were found'
    scroll_to_bottom
    expect(all('.page_row').count).to be > dom_count, "Additional page rows weren't added after scroll"
  end

  scenario 'scrolling is infinite / loads and renders more posts when the end of the page is reached' do
    limit = 3
    user = users(:greg)
    login_as user, scope: :user

    visit "/#{user.username}/list?limit=#{limit}"

    dom_count = all('.r_subpost').count
    expect(dom_count).to eq(limit), 'Not enough posts were found'
    scroll_to_bottom
    expect(all('.r_subpost').count).to eq(limit * 2), "Additional page rows weren't added after scroll"
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
      find('.comments_icon').click
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

  scenario 'clicking a post delete button deletes a post' do
    login_as users(:greg), scope: :user
    db_count = Post.count

    visit '/'
    scroll_to_bottom

    row = nil
    all('.pa_destroy').each do |el|
      row = first_row_containing(el)
      if row.all('.r_subpost').count > 1
        break
      else
        row = nil
      end
    end

    expect(row).to be_truthy, "A page with more than one subpost wasn't found"

    within(row) do
      dom_count = all('.r_subpost').count
      find('.pa_destroy').click
      page.driver.browser.switch_to.alert.accept
      wait_for_js
      expect(page).to have_selector('.pa_create'), "Post button didn't change state"
      expect(page).to have_selector('.r_subpost', count: dom_count - 1)
    end

    expect(Post.count).to eq(db_count - 1), "Post wasn't removed from the database"
  end

  scenario 'deleting the last post removes the page from the DOM' do
    login_as users(:greg), scope: :user
    db_count = Post.count

    visit '/'
    scroll_to_bottom
    dom_count = all('.page_row').count

    row = nil
    all('.pa_destroy').each do |el|
      row = first_row_containing(el)
      break if row.all('.r_subpost').count == 1
    end

    expect(row).to be_truthy, "A page with only one subpost wasn't found"

    within(row) do
      find('.pa_destroy').click
      page.driver.browser.switch_to.alert.accept
      wait_for_js
    end

    expect(all('.page_row').count).to eq(dom_count - 1), "Page wasn't removed from the DOM"
    expect(Post.count).to eq(db_count - 1), "Post wasn't removed from the database"
  end

  shared_context 'a yep nope button' do |yn|
    scenario "clicking a #{yn} button toggles #{yn} on a post" do
      login_as users(:greg), scope: :user
      query = Post.where(yn: yn.to_s == 'yep')
      db_count = query.count

      visit '/'
      scroll_to_bottom

      row = nil
      all('.pa_destroy').each do |el|
        row = first_row_containing(el)
        if row.all(".pa_#{yn}.r_active").count == 0
          break
        else
          row = nil
        end
      end

      expect(row).to be_truthy, "A posted page that didn't already have #{yn} wasn't found"

      within(row) do
        dom_count = all(".r_subpost .r_#{yn}").count
        
        find(".pa_#{yn}").click
        wait_for_js
        expect(page).to have_selector(".pa_#{yn}.r_active"), "#{yn} button didn't change state"
        expect(page).to have_selector(".r_subpost .r_#{yn}", count: dom_count + 1), "A post wasn't newly marked as '#{yn}'"
        expect(query.count).to eq(db_count + 1), "Post wasn't maked as '#{yn}' in the database"

        find(".pa_#{yn}").click
        wait_for_js
        expect(page).not_to have_selector(".pa_#{yn}.r_active"), "#{yn} button didn't change state"
        expect(page).to have_selector(".r_subpost .r_#{yn}", count: dom_count), "'#{yn}' wasn't removed from the subpost DOM"
        expect(query.count).to eq(db_count), "'#{yn}' wasn't removed from the post in the database"
      end
    end
  end

  it_behaves_like 'a yep nope button', :yep
  it_behaves_like 'a yep nope button', :nope
end
