# encoding: utf-8
class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :visit]
  
  # GET /posts
  # GET /posts.xml
  def index
    @posts =  Post.order("created_at DESC")
                  .includes([:user, :page, :domain, {:referrer_post => :user}])
                  .paginate(:page => params[:page])
    @channels = 'everybody'
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      @post.destroy
    end

    respond_to do |format|
      format.html { redirect_to("/#{current_user.username}") }
      format.xml  { head :ok }
    end
  end

  # A note about schema
  # The original idea was that the referrer_id didn't
  # have to dictate the :url param - that way we could
  # eventually mix and match 'because of' with different
  # end results. Otherwise we could just forward straight
  # without the intermediate page.
  # I've considered doing this with the URL shortener,
  # but Rails make sharing code between controller methods
  # a pain in the ass
  def visit
    # this is disabled while I look for some funny business
    #@token = if params[:token] then params[:token] elsif signed_in? then current_user.token else '' end
    @token = if params[:token] == '-' then params[:token] elsif signed_in? then current_user.token else '' end
    @referrer_id = 0 # default

    if !params[:id]
      # Pass through and post any domain, even
      # if it's not already in the system
      # schema: reading.am/http://example.com
    else
      @referrer_id = Base58.decode(params[:id])
      @ref = Post.find(@referrer_id)

      if !params[:url]
        # Post from a referrer id only
        # Currently only used for the shortener
        # schema: ing.am/p/xHjsl
        redirect_to @ref.wrapped_url
      else
        # Post through the classic JS method
        # Facebook hits this page to grab info
        # for the timeline
        @page_title = "✌ #{@ref.page.display_title}"
        @og_props = {
          :type => @ref.page.media_type,
          :title => @page_title,
          :image => @ref.page.image,
          :description => @ref.page.description
        }
      end
    end
  end

  def test
    respond_to do |format|
      format.html { render locals: { name: 'David' }, template: Rails.root.join('app', 'assets', 'javascripts', 'backbone', 'templates', 'test.html.hbs').to_s, layout: false }
    end
    
  end

end
