# encoding: utf-8
class RssController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @page = Page.find_by_url("#{params[:url]}/")

    @posts = []
    user = User.find(1)
    i = 1

    @page.remote_rss.search("item").each do |item|
      post = Post.new(
        :user => user,
        :page => Page.new(
          :url => item.search("link").first.content,
          :title => item.search("title").first.content
        ),
        :created_at => Time.now,
        :updated_at => Time.now
      )
      post.id = i
      post.page.id = i
      i += 1
      @posts << post
    end

    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
    end
  end

end
