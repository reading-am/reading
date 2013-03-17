class CleanupPageUrls < ActiveRecord::Migration
  def up
    Page.observers.disable :all
    Post.observers.disable :all
    Comment.observers.disable :all

    Page.where("url ~* 'http://http:/'").each do |page|
      page.url = "http://#{page.url[13..-1]}"
      replacement = Page.find_by_url(page.url) rescue nil
      if !replacement.blank?
        page.posts.each do |post|
          post.page = replacement
          post.save
        end
        page.comments.each do |comment|
          comment.page = replacement
          comment.save
        end
        page.destroy
      else
        page.save
      end
    end

    Page.find_each do |page|
      page.url = Page.cleanup_url(page.url)
      if page.url_changed?
        puts "Processing #{page.id} : #{page.url_was} : #{page.url}"
        replacement = Page.find_by_url(page.url) rescue nil
        if !replacement.blank?
          page.posts.each do |post|
            post.page = replacement
            post.save
          end
          page.comments.each do |comment|
            comment.page = replacement
            comment.save
          end
          page.destroy
        else
          page.save
        end
      end
    end

    Page.observers.enable :all
    Post.observers.enable :all
    Comment.observers.enable :all
  end

  def down
  end
end
