# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :followingers, :delete_cookies, :tagalong, :find_people]

  # GET /users/1
  # GET /users/1.xml
  def show
    if params[:username].blank? || params[:username] == 'everybody'
      @posts = Post.all
    else
      @user = params[:username] ? User.find_by_username(params[:username]) : User.find(params[:id])
      if !@user then not_found end
      @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})" << " on ✌ Reading"
      @posts = params[:type] == 'list' ? @user.feed : @user.posts
    end

    if !params[:medium].blank?
      ids = @posts.joins(:page)
                  .where(pages: {medium: params[:medium]})
                  .order("posts.created_at DESC")
                  .limit(50)
                  .pluck(:id)

      @posts = Post.where(:id => ids)
    end

    @posts = @posts.includes(:user, :page, {referrer_post: :user})
                   .order("posts.created_at DESC")
                   .limit(50)

    respond_to do |format|
      format.html { render 'posts/index' }
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

  def find_people
  end
end
