# From: http://pusher.com/docs/authenticating_users
# Using https://github.com/pusher/pusher-gem
class PusherController < Api::APIController

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
  add_transaction_tracer :auth

  def existence
    event = ActiveSupport::JSON.decode(request.raw_post)['events'].first
    if (event['channel'] =~ /^users\.[0-9]*\.feed$/) == 0 \
      and ['channel_occupied','channel_vacated'].include? event['name']
      User.where(:id => event['channel'].split('.')[1])
          .update_all(:feed_present => (event['name'] == 'channel_occupied'))
    end
    respond_to do |format|
      format.html {head :ok}
    end
  end
  add_transaction_tracer :existence

end
