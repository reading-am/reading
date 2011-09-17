class HomeController < ApplicationController
  before_filter :check_login
  
  def index
    @posts = Post.order("created_at DESC").limit(50)
    Pusher['test_channel'].trigger_async('my_event', {
      :some => 'data'
    })
  end
end
