# encoding: utf-8
class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
    if @page.domain.name != params[:domain_id]
      redirect_to "/domains/#{@page.domain.name}/pages/#{@page.id}"
    else
      respond_to do |format|
        format.html  # show.html.erb
      end
    end
  end

  def group
    @result = Comment.joins(:page, :post, :user).where("body LIKE ?", "##{params[:id]}%")
    respond_to do |format|
      format.json {
        render json: @result.to_json(:include => [ :page, :post, :user ])
      }
      format.html
    end
  end

end

