# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  http_basic_authenticate_with :name => 'reading', :password => 'issomuchfun' if Rails.env == 'staging'

  before_filter :check_domain, :set_user_device, :set_headers
  helper_method :current_user, :logged_in?, :mobile_device?, :desktop_device?

  rescue_from ActiveRecord::RecordNotFound, :with => :show_404

  private

  def set_time_zone
    min = cookies[:timezone].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def set_headers
    if request.format == 'rss'
      # settings borrowed from Twitter's RSS headers: https://twitter.com/statuses/user_timeline/27260086.rss
      response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, pre-check=0, post-check=0"
      response.headers["Pragma"] = "no-cache"
      response.headers["Keep-Alive"] = "timeout=15, max=100"
    end
  end

  def current_user
    if cookies[:auth_token]
      begin
        @current_user ||= User.find_by_auth_token!(cookies[:auth_token])
      rescue
        cookies.delete(:auth_token)
        nil
      end
    end
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

  def check_domain
    # redirect our url shorten to the root domain if it's not hitting the posts path
    if ['ing.am','ing.dev'].include? request.domain and request.path[0,3] != '/p/'
      redirect_to request.url.sub(/ing/,'reading')
    end
  end

  def check_login
    if logged_in? and request.path_info == '/'
      if current_user.username
        redirect_to "/#{current_user.username}/list"
      else
        redirect_to '/pick_a_url'
      end
    end
  end

  def is_mobile_safari_request? # from: http://www.ibm.com/developerworks/opensource/library/os-eclipse-iphoneruby1/
    request.user_agent =~ /(Mobile\/.+Safari)/
  end
  
  def is_iphone_or_ipod_request?
    if !request.user_agent then return false end
    ua = request.user_agent.downcase
    ua.index('iphone') || ua.index('ipod')
  end

  def set_user_device
    if is_iphone_or_ipod_request?
      @user_device = :mobile
    else
      @user_device = :desktop
    end
  end

  def mobile_device?
    @user_device == :mobile
  end

  def deskotp_device?
    @user_device == :desktop
  end

  def not_found
    raise ActiveRecord::RecordNotFound.new
  end

  def show_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found}
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

end
