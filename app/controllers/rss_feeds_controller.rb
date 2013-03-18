# encoding: utf-8
class RssFeedsController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @page = Page.find_by_url("#{params[:url]}/")

    @user = User.new(
      :username => @page.rss_feed.title,
      :name => @page.rss_feed.title
    )

    @posts = @page.rss_feed.posts
  end

end
