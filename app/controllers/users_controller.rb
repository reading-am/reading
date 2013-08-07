# encoding: utf-8
class UsersController < ApplicationController

  before_filter :authenticate_user!, except: [:show, :followingers, :delete_cookies, :tagalong, :find_people]
  before_filter :set_default_params

  def set_default_params
    params[:limit] = 50
    params[:offset] = 0
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    if params[:username] && params[:username] != 'everybody'
      @user = params[:username] ?
                User.find_by_username(params[:username]) :
                User.find(params[:id])

      if !@user then not_found end
      params[:user_id] = @user.id

      @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})" << " on ✌ Reading"
    end

    p = params.clone
    p[:type] = "following" if params[:type] == "list"

    @posts = Api::Posts.index(p)

    respond_to do |format|
      format.html { render 'posts/index' }
      format.rss  { render 'posts/index' }
    end
  end

  def settings
    redirect_to "/settings/info"
  end

  def followingers
    @user = params[:username] ?
              User.find_by_username(params[:username]) :
              User.find(params[:id])

    params[:user_id] = @user.id
    collection = Api::Relationships.index(params)
    @users = collection.to_a.map { |u| u.simple_obj } if bot?

    respond_to do |format|
      format.html { render locals: { collection: collection } }
    end
  end

  def recommended
    params[:user_id] = current_user.id
    collection = Api::Users.recommended(params)
    @users = collection.to_a.map { |u| u.simple_obj } if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_recommended: true, collection: collection } }
    end
  end

  def expats
    params[:user_id] = current_user.id
    collection = Api::Users.expats(params)
    @users = collection.to_a.map { |u| u.simple_obj } if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_expats: true, collection: collection } }
    end
  end

  def search
    collection = Api::Users.search(params)
    @users = collection.to_a.map { |u| u.simple_obj } if bot?

    respond_to do |format|
      format.html { render 'find_people', locals: { section_search: true, collection: collection } }
    end
  end

  def hooks
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks
    @authorizations = @user.authorizations

    respond_to do |format|
      format.html { render 'hooks/index' }
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

end
