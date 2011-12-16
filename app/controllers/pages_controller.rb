class PagesController < ApplicationController
  def search
    @pages = Page.with_query(params[:q]).paginate(:page => params[:page])
  end
end
