# encoding: utf-8
module Api::V1
  class PagesController < ApiController

    private

    def page_params
      params.require(:model).permit(:html)
    end

    public

    def index
      @pages = Page.order("created_at DESC")
               .paginate(:page => params[:page])

      render
    end
    add_transaction_tracer :index

    def show
      @page = Page.find(params[:id])
      render
    end
    add_transaction_tracer :show

    def update
      @page = Page.includes(:describe_data).find(params[:id])

      respond_to do |format|
        if !current_user
          response = :forbidden
        elsif page_params[:html]
          @page.populate_describe_data page_params[:html]
          @page.save
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
end