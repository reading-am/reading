# encoding: utf-8
class RssController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @page = Page.find_by_url("#{params[:url]}/")

    uname = @page.remote_rss.search("channel title").first.content
    @user = User.new(
      :username => uname,
      :name => uname
    )

    @posts = []
    user = User.find(1)
    i = 1

    @page.remote_rss.search("item").each do |item|
      post = Post.new(
        :user => user,
        :page => Page.new(
          :url => item.search("link").first.content,
          :title => item.search("title").first.content,
          :r_excerpt => item.search("description").first.content
        ),
        :created_at => Time.now,
        :updated_at => Time.now
      )
      post.id = i
      post.page.id = i
      i += 1
      @posts << post
    end
  end

end
