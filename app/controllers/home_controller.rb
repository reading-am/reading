class HomeController < ApplicationController
  before_filter :check_login

  def index
    @posts = Post.order("created_at DESC").limit(50)
    @channels = 'everybody'
  end
end
