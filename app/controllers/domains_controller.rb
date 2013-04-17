# encoding: utf-8
class DomainsController < ApplicationController
  # GET /domains/1
  # GET /domains/1.xml
  def show
    @domain = Domain.fetch_by_name(params[:domain_name])
    @posts = @domain.posts.order("created_at DESC").paginate(:page => params[:page])

    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
    end
  end

end
