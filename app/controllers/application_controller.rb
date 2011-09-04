class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone, :set_headers

  helper_method :current_user, :logged_in?

  private

  def set_time_zone
    min = cookies[:timezone].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def set_headers
    if request.format == 'rss'
      # settings borrowed from Twitter's RSS headers: https://twitter.com/statuses/user_timeline/27260086.rss
      response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, pre-check=0, post-check=0, max-age=0"
      response.headers["Pragma"] = "no-cache"
      response.headers["Keep-Alive"] = "timeout=15, max=100"
    end
  end

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate
    # This should probably be throwing some sort of error
    # instead of simply redirecting, especially for AJAX requests
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
