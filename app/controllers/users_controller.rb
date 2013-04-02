# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :followingers, :delete_cookies, :tagalong, :find_people]

  # GET /users/1
  # GET /users/1.xml
  def show
    if params[:username] == 'everybody'
      @posts  = Post.order("created_at DESC")
                    .includes([:user, :page, :domain, {:referrer_post => :user}])
                    .paginate(:page => params[:page])
      @channels = 'everybody'
    else
      @user = params[:username] ?
        User.find_by_username(params[:username]) :
        User.find(params[:id])
      if !@user then not_found end

      @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})" << " on ✌ Reading"

      if params[:type] == 'list'
        @posts = @user.feed.paginate(:page => params[:page])
        @channels = @user.following.map { |user| user.username }
        # add the user to the channels since it's not in .following()
        @channels.push @user.username
      else
        @posts = @user.posts.order("created_at DESC").paginate(:page => params[:page])
        @channels = @user.username
      end
    end

    _pages = []
    date = ''
    @posts.group_by(&:page).each_with_index do |(page, subposts), i|
      _page = page.simple_obj
      _page[:url] = subposts.first.wrapped_url
      _page[:posts] = []

      if date != subposts.first.created_at.strftime("%m/%d")
        _page[:date] = date = subposts.first.created_at.strftime("%m/%d")
      else
        yn_avg = 0
        #yn_avg = yn_average subposts
        if yn_avg > 0
          _page[:yn_class] = "yep"
          _page[:yep] = true
        elsif yn_avg < 0
          _page[:yn_class] = "nope"
          _page[:nope] = true
        end
      end

      subposts.each do |post|
        _post = post.simple_obj

        _post[:yep] = post.yn === true
        _post[:nope] = post.yn === false

        _post[:user][:size] = "small"
        _post[:user].delete(:username)
        _post[:user].delete(:bio)

        _page[:posts] << _post
      end
      _page[:has_comments] = _page[:comments_count] > 0
      _pages << _page
    end
    @pages = _pages

    respond_to do |format|
      format.html { render 'posts/index/template' }
      format.xml  { render 'posts/index', :xml => @posts }
      format.rss  { render 'posts/index' }
    end
  end

  def settings
    redirect_to "/settings/info"
  end

  def followingers
    @user = User.find_by_username(params[:username])
    @users = (params[:type] == 'followers') ? @user.followers : @user.following
  end

  def hooks
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks

    respond_to do |format|
      format.html { render 'hooks/index' }
      format.xml  { render 'hooks/index', :xml => @hooks }
      format.rss  { render 'hooks/index' }
    end
  end

  def delete_cookies
    cookies.each do |k, v| cookies.delete k end
    redirect_to '/'
  end

  def export
    user = User.find_by_username(params[:username])
    if user == current_user
      respond_to do |format|
        format.csv { render 'posts/export', :layout => false, :locals => {:posts => user.posts} }
      end
    else
      show_404
    end
  end

  def extras
    @user = current_user
    @post_email = MailPipe::encode_mail_recipient('post', current_user, current_user)
  end

  def tagalong
    @user = User.find(params[:user_id])

    case params[:dir]
    when "next"
      @post = @user.posts.where("id > ?", params[:post_id]).order("id ASC").limit(1).first
    when "prev"
      @post = @user.posts.where("id < ?", params[:post_id]).order("id DESC").limit(1).first
    end

    if @post.blank?
      redirect_to "/#{@user.username}", :notice => "You've reached the end of #{@user.first_name}'s posts. Thanks for tagging along!"
    else
      redirect_to @post.wrapped_url
    end
  end

  def find_people
  end
end
