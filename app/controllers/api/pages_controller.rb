# encoding: utf-8
class Api::PagesController < Api::APIController

  def index
   @pages = Page.order("created_at DESC")
                .paginate(:page => params[:page])

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end

  def show
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

