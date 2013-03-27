# encoding: utf-8
class PagesController < ApplicationController

  def show
    @page = Page.fetch(params[:id])
    if @page.domain.name != params[:domain_id]
      redirect_to "/domains/#{@page.domain.name}/pages/#{@page.id}"
    else
      respond_to do |format|
        format.html  # show.html.erb
      end
    end
  end

end

