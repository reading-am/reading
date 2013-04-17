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
    @page = Page.fetch(params[:id])

    respond_to do |format|
      format.json { render_json :page => @page.simple_obj }
    end
  end

  def search
    search = Page.search do
      fulltext params[:q] do boost_fields :title => 3.0 end
    end

    @pages = search.results

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end

  def count
    if current_user.roles? :admin
      respond_to do |format|
        format.json { render_json :total_pages => Page.count }
      end
    else
      show_404
    end
  end

end

