# From: http://pusher.com/docs/authenticating_users
# Using https://github.com/pusher/pusher-gem
class PusherController < ApplicationController
  protect_from_forgery :except => :auth # stop rails CSRF protection for this action
  skip_before_filter :protect_staging # for some reason, http auth prevents this endpoint from working

  def auth
    @user = params[:token] ? User.fetch_by_token(params[:token]) : current_user
    if !@user.blank?
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        :user_id => @user.id, # => required
        #:user_info => { # => optional - for example
          #:name => @user.name
        #}
      })
      render :json => response, :callback => params[:callback]
    else
      render :text => "Forbidden", :status => '403'
    end
  end
end
