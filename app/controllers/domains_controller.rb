# encoding: utf-8
class DomainsController < ApplicationController
  def show
    @domain = Domain.find_by_name(params[:id])
    params[:domain_id] = @domain.id
    @posts = api::Posts.index(params)
    render 'posts/index'
  end
end
