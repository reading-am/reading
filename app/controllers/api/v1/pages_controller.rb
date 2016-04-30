# encoding: utf-8
module Api::V1
  class PagesController < ApiController

    private

    def page_params
      params.require(:model).permit(:html)
    end

    public

    def index
      pages = Pages.index(params)
      render locals: { pages: pages }
    end
    require_scope_for :index, :public
    add_transaction_tracer :index

    def show
      render locals: { page: Page.find(params[:id]) }
    end
    require_scope_for :show, :public
    add_transaction_tracer :show

    def update
      page = Page.includes(:describe_data).find(params[:id])

      if page_params[:html]
        page.populate_describe_data page_params[:html]
        page.save
      else
        page.update_attributes(page_params)
      end

      render :show, locals: { page: page }
    end
    require_scope_for :update, :write
    add_transaction_tracer :update

    def count
      render_json total_pages: Page.count
    end
    require_scope_for :count, :admin
    add_transaction_tracer :count
  end
end
