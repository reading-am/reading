# From: http://pusher.com/docs/authenticating_users
# Using https://github.com/pusher/pusher-gem
class PusherController < Api::V1::ApiController

  def auth
    @user = params[:token] ? User.find_by_token(params[:token]) : current_user
    if !@user.blank?
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {user_id: @user.id})
      render json: response, callback: params[:callback]
    else
      render text: 'Forbidden', status: 403
    end
  end
  add_transaction_tracer :auth

  def existence
    webhook = Pusher.webhook(request)
    if webhook.valid?
      webhook.events.each do |event|
        if (event['channel'] =~ /^users\.[0-9]*\.following\.posts/) == 0 \
          and ['channel_occupied','channel_vacated'].include? event['name']
          User.where(:id => event['channel'].split('.')[1])
              .update_all(:feed_present => (event['name'] == 'channel_occupied'))
        end
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end
  add_transaction_tracer :existence

end
