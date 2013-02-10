class BackfillPageHeaderTags < ActiveRecord::Migration
  def up
    Page.where(:head_tags => nil).order('id ASC').limit(10).find_each do |page|
      page.populate_remote_data
      if page.url_changed?
        dupe_page = Page.find_by_url page.url
        if dupe_page
          if dupe_page.id < page.id
            puts "#{page.id} getting replaced by #{dupe_page.id}\n"
            page_to_replace = page
            page_to_keep = dupe_page
          else
            puts "#{page.id} replacing #{dupe_page.id}\n"
            puts "url was: #{page.url_was}\nurl is: #{page.url}\n\n"
            page.domain = Domain.find_or_create_by_name(Addressable::URI.parse(page.url).host)
            page_to_replace = dupe_page
            page_to_keep = page
          end
          page_to_replace.posts.each do |post|
            post.page = page_to_keep
            post.save
          end
          page_to_replace.comments.each do |comment|
            comment.page = page_to_keep
            comment.save
          end
          page_to_replace.destroy
        end
      end
      if !page.destroyed?
        page.save
        puts "#{page.id} populated and saved"
      else
        puts "#{page.id} destroyed"
      end
    end
  end

  def down
  end
end
