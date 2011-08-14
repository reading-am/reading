class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone

  helper_method :current_user, :logged_in?

  private

  def set_time_zone
    min = cookies[:timezone].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate
    if !logged_in?
      redirect_to root_path
    end
  end

  def check_login
    if current_user
      if current_user.username
        redirect_to "/#{current_user.username}"
      else
        redirect_to '/pick_a_url'
      end
    end
  end
end
