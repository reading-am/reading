# encoding: utf-8
class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:show, :followingers, :delete_cookies, :tagalong, :find_people, :suspended]

  def show
    if params[:username] && params[:username] != 'everybody'
      @user = params[:username] ?
                User.find_by_username!(params[:username]) :
                User.find(params[:id])

      if @user.suspended? then return redirect_to '/support/suspended' end
      params[:user_id] = @user.id

      @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})" << " on ✌ Reading"
    end

    # The web url uses 'list' to denote posts from users you're following
    @posts = api::Posts.index(if params[:type] == 'list'
                                params.merge(type: 'following')
                              else
                                params
                              end)
    render 'posts/index'
  end

  def settings
    redirect_to "/settings/info"
  end

  def followingers
    @user = params[:username] ?
              User.find_by_username!(params[:username]) :
              User.find(params[:id])

    params[:user_id] = @user.id
    collection = api::Relationships.index(params)
    @users = render_api('users/index', users: collection) if bot?

    respond_to do |format|
      format.html { render locals: { collection: collection } }
    end
  end

  def recommended
    params[:user_id] = current_user.id
    collection = api::Users.recommended(params)
    @users = render_api('users/index', users: collection) if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_recommended: true, collection: collection } }
    end
  end

  def expats
    params[:user_id] = current_user.id
    collection = api::Users.expats(params)
    @users = render_api('users/index', users: collection) if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_expats: true, collection: collection } }
    end
  end

  def search
    collection = api::Users.search(params)
    @users = render_api('users/index', users: collection) if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_search: true, collection: collection } }
    end
  end

  def hooks
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks
    @authorizations = @user.authorizations

    render 'hooks/index'
  end

  def apps
    @user = current_user
    @tokens = @user.active_oauth_access_tokens

    render 'oauth_access_tokens/index'
  end

  def dev_apps
    @user = current_user
    @apps = @user.oauth_owner_apps

    respond_to do |format|
      format.html { render 'oauth_apps/index' }
    end
  end

  def delete_cookies
    cookies.each do |k, v| cookies.delete k end
    redirect_to '/'
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

  def suspended
  end

end
