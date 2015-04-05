require 'rails_helper'

shared_context 'a yep nope button' do |yn|
  scenario "toggles #{yn} clicking a #{yn} button" do
    query = user.posts.where(yn: yn.to_s == 'yep')
    db_count = query.count

    visit url
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

shared_context 'is shareable' do
  scenario 'by displaying a share sheet after clicking a share button' do
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

shared_context 'visits user' do
  scenario 'by navigating to user page upon click' do
    name = user_link.text
    user_link.click

    expect(current_path).to match(/\/[^\/]+/), "Path wasn't a root user path"
    expect(first('h1')).to have_text(name)
  end
end
