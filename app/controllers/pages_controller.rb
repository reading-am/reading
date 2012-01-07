class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
    if @page.domain.name != params[:domain_id]
      redirect_to "/domains/#{@page.domain.name}/pages/#{@page.id}"
    else
      respond_to do |format|
        format.html  # show.html.erb
        format.json  { render :json => @page }
      end
    end
  end

end

