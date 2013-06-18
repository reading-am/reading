# encoding: utf-8
class Api::PagesController < Api::APIController

  def index
   @pages = Page.order("created_at DESC")
                .paginate(:page => params[:page])
                .skeletal

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end
  add_transaction_tracer :index

  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.json { render_json :page => @page.simple_obj }
    end
  end
  add_transaction_tracer :show

  def search
    search = Page.search do
      fulltext params[:q] do boost_fields :title => 3.0 end
    end

    @pages = search.results

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end
  add_transaction_tracer :search

  def count
    if current_user.roles? :admin
      respond_to do |format|
        format.json { render_json :total_pages => Page.count }
      end
    else
      show_404
    end
  end
  add_transaction_tracer :count

end

