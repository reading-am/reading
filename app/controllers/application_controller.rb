# encoding: utf-8
class ApplicationController < ActionController::Base
  # needed for migrate_auth_token
  include Devise::Controllers::Rememberable

  protect_from_forgery

  before_filter :protect_staging, :check_domain, :set_user_device, :set_headers, :migrate_auth_token, :check_signed_in
  helper_method :mobile_device?, :desktop_device?

  rescue_from ActiveRecord::RecordNotFound, :with => :show_404

  private

  def protect_staging
    if Rails.env == 'staging'
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == ENV['READING_AUTH_BASIC_USER'] && password == ENV['READING_AUTH_BASIC_PASS']
      end
    end
  end

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

  def migrate_auth_token
    token = cookies.delete(:auth_token)
    if !token.blank? and user = User.find_by_auth_token(token) rescue false
      sign_in user
      remember_me user
    end
  end

  def check_signed_in
    if signed_in?
      # check for 'destroy' so the user can delete themselves if need be
      if (controller_path == 'users' or (controller_path == 'posts' and action_name == 'index')) and (current_user.username.blank? or current_user.email.blank? or !current_user.has_pass?)
        redirect_to '/almost_ready'
      elsif request.path_info == '/'
        redirect_to "/#{current_user.username}/list"
      end
    end
  end

  def check_domain
    # redirect our url shortener to the root domain if it's not hitting the posts path
    if ['ing.am','ing.dev'].include? request.domain and request.path[0,3] != '/p/'
      redirect_to request.url.sub(/ing/,'reading')
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
      format.html {
        render :file => "#{Rails.root}/public/404.html",
        :layout => false,
        :status => :not_found
      }
      format.any { head :not_found }
    end
  end

end
