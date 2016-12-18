# encoding: utf-8
class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:visit]

  # A note about schema
  # The original idea was that the referrer_post_id didn't
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
    @referrer_post_id = Base58.decode(params[:id]) rescue 0

    # Pass through and post any domain, even
    # if it's not already in the system
    # schema: reading.am/http://example.com
    return unless @referrer_post_id

    @ref = Post.find(@referrer_post_id)

    if !params[:url]
      # Post from a referrer id only
      # Currently only used for the shortener
      # schema: ing.am/p/xHjsl
      redirect_to @ref.wrapped_url
    else
      # Post through the classic JS method
      # Facebook hits this page to grab info
      # for the timeline
      @url = @ref.page.url
      @page_title = "✌ #{@ref.page.display_title}"
      @og_props = {
        type: @ref.page.media_type,
        title: @page_title,
        # image: @ref.page.image,
        description: @ref.page.description
      }
    end
  end
end
