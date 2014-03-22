# encoding: utf-8
class Api::PagesController < Api::APIController

  private

  def page_params
    params.require(:model).permit(:html)
  end

  public

  def index
   @pages = Page.order("created_at DESC")
                .paginate(:page => params[:page])

    respond_to do |format|
      format.json { render_json :pages => @pages.collect { |page| page.simple_obj } }
    end
  end
  add_transaction_tracer :index

  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.json { render_json page: @page.simple_obj }
    end
  end
  add_transaction_tracer :show

  def update
    @user  = params[:token] ? User.find_by_token(params[:token]) : current_user
    @page = Page.find(params[:id], include: :describe_data)

    respond_to do |format|
      if !@user
        response = :forbidden
      elsif page_params[:html]
        # if you don't specifcy the page here, DescribeData
        # parse will only have the id instead of the full model and will query
        @page.build_describe_data page: @page if @page.describe_data.blank?
        @page.describe_data.parse page_params[:html]
        @page.populate_remote_data
        response = @page.simple_obj
      elsif @page.update_attributes(page_params)
        response = :ok
      else
        response = :unprocessable_entity
      end
      format.json { render_json response }
    end
  end
  add_transaction_tracer :update

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

