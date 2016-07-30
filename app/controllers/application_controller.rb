# encoding: utf-8
class ApplicationController < ActionController::Base
  include RenderApi
  include DefaultParams

  protect_from_forgery

  before_action :protect_staging, :check_domain, :set_user_device,
                :set_headers, :migrate_to_www,
                :check_signed_in, :set_bot, :profiler, :set_default_params

  helper_method :mobile_device?, :desktop_device?, :bot?, :render_api

  rescue_from ActiveRecord::RecordNotFound, with: :show_404

  private

  def profiler
    Rack::MiniProfiler.authorize_request if defined?(Rack::MiniProfiler) && signed_in? && current_user.roles?(:admin)
  end

  def protect_staging
    if Rails.env == 'staging'
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == ENV['AUTH_BASIC_USER'] && password == ENV['AUTH_BASIC_PASS']
      end
    end
  end

  def set_time_zone
    min = cookies[:timezone].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def set_headers
    set_no_cache_headers if request.format == 'rss'
  end
  
  def set_no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, pre-check=0, post-check=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def migrate_to_www
    # scan for a root domain
    if request.host != SHORT_DOMAIN && request.host.scan(/\w\.[a-z]/i).length == 1
      if t = cookies[:remember_user_token]
        cookies.delete :remember_user_token
        cookies[:remember_user_token] = {value: t, domain: :all}
      end
      redirect_to request.url.sub(request.host, "www.#{request.host}"), status: :moved_permanently
    end
  end

  def check_signed_in
    if signed_in?
      if current_user.suspended? and !(controller_path == 'users' and action_name == 'suspended')
        redirect_to '/support/suspended'
      elsif (controller_path == 'users' or (controller_path == 'registrations' and action_name == 'edit') or (controller_path == 'posts' and action_name == 'index')) and (current_user.username.blank? or current_user.email.blank? or !current_user.has_pass?)
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

  def set_bot
    if request.user_agent.blank?
      @bot = 'no-agent'
    else
      # Alternatively, we could use this gem: https://github.com/biola/Voight-Kampff
      agents = [
        'msnbot',
        'yahoo',
        'y!', # Yahoo Japan
        'google',
        'facebook',
        'bingbot',
        'duckduckbot',
        'yandex',
        'teoma', # Ask.com
        'baidu',
        'gigabot',
        'ia_archiver', # Alexia and Archive.org
        'asterias', # AOL
      ]
      @bot = agents.detect {|bot| request.user_agent.include? bot }
    end
  end

  def bot?
    !@bot.blank?
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

  def api
    "Api::V#{API_VERSION}".constantize
  end
end
