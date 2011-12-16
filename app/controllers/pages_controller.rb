class PagesController < ApplicationController
  def search
    @pages = Page.find_with_index(params[:q])
  end
end
