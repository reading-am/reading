# encoding: utf-8
class DomainsController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @domain = Domain.find_by_name(params[:id])
    params[:domain_id] = @domain.id
    @posts = Api::Posts.index(params)

    respond_to do |format|
      format.html { render 'posts/index' }
      format.rss  { render 'posts/index' }
    end
  end

end
