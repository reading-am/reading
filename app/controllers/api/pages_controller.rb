# encoding: utf-8
class Api::PagesController < ApplicationController

  def index
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'POST'
        return create()
      end
    end

   @pages = Page.order("created_at DESC")
                .paginate(:page => params[:page])

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end

  def show
    # for JSONP requests
    if !params[:_method].blank?
      case params[:_method]
      when 'PUT'
        return update()
      when 'DELETE'
        return destroy()
      end
    end

    @page = Page.find(params[:id])

    respond_to do |format|
      format.json { render_json :page => @page.simple_obj }
    end
  end

  def comments
    @page = Page.find(params[:id])
    respond_to do |format|
      format.json { render_json :comments => @page.comments.collect { |comment| comment.simple_obj } }
    end
  end

end

