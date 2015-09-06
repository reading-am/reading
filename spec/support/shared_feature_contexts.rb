require 'rails_helper'

shared_context 'a yep nope button' do |yn|
  scenario "toggles #{yn} clicking a #{yn} button" do
    query = user.posts.where(yn: yn.to_s == 'yep')
    db_count = query.count

    visit url
    scroll_to_bottom

    row = nil
    all('.pa_destroy').each do |el|
      row = first_parent_with_class_containing('page_row', el)
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

shared_context 'is shareable' do
  scenario 'by displaying a share sheet after clicking a share button' do
    whitelist 'https://twitter.com/*'
    share_link.click
    expect(page).to have_selector('#r_share_menu'), "Share menu wasn't displayed"

    click_link('Twitter')
    expect(windows.length).to eq(2)

    within_window(windows.last) do
      expect(current_url).to start_with('https://twitter.com/intent')
      current_window.close
    end
  end
end

shared_context 'visits user' do |iframe|
  scenario 'by navigating to user page upon click' do
    name = user_link.text
    user_link.click

    if iframe
      within_frame('r_user_overlay') do
        expect(current_path).to match(/\/[^\/]+/), "Path wasn't a root user path"
        expect(first('h1')).to have_text(name)
      end
    else
      expect(current_path).to match(/\/[^\/]+/), "Path wasn't a root user path"
      expect(first('h1')).to have_text(name)
    end
  end
end

shared_context 'comment input' do
  scenario 'creates a new comment' do
    count = user.comments.count
    body = 'This is a comment'

    find_field('Add a comment')
      .send_keys(body)
      .send_keys(:return)
    wait_for_js

    expect(first('.r_comment')).to have_text(body), "Comment wasn't added to the DOM"
    expect(user.comments.count).to eq(count + 1), "Comment wasn't added to the database"
    expect(user.comments.last.body).to eq(body)
  end
end

shared_context 'comment delete button' do
  scenario 'deletes a comment' do
    db_count = user.comments.count
    dom_count = all('.r_comment').count

    first_parent_with_class_containing('r_comment', first('.r_comment .r_name', text: user.name)).hover
    accept_confirm { click_link('Delete') }
    wait_for_js

    expect(all('.r_comment').count).to eq(dom_count - 1)
    expect(user.comments.count).to eq(db_count - 1)
  end
end

shared_context 'comment permalink button' do
  scenario 'goes to the comment page' do
    body = first('.r_comment_body')
    comment = first_parent_with_class_containing('r_comment', body)
    comment.hover
    comment.click_link('#')

    expect(windows.length).to eq(2)

    within_window(windows.last) do
      expect(current_path).to match(/\/[^\/]+\/comments\/\d+/)
      current_window.close
    end
  end
end
