# encoding: utf-8
class RssController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @page = Page.find_by_url("#{params[:url]}/")
    debugger
    @posts = @page.posts.order("created_at DESC").paginate(:page => params[:page])

    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
    end
  end

end
