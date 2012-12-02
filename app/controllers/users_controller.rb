# encoding: utf-8
class UsersController < ApplicationController
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

    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
      format.rss  { render 'posts/index' }
    end
  end

  def settings
    redirect_to user_signed_in? ? "/settings/info" : "/"
  end

  # GET /users/1/edit
  def edit
    redirect_to "/" and return if !user_signed_in?
    @user = current_user
    if params[:user] and @user.update_attributes(params[:user])
      redirect_to("/settings/info", :notice => 'User was successfully updated.')
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    if @user != current_user
      redirect_to root_url and return
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find_by_username(params[:id])
    if @user == current_user
      @user.destroy
    end

    respond_to do |format|
      format.html { redirect_to('/signout') }
      format.xml  { head :ok }
    end
  end

  def followingers
    @user = User.find_by_username(params[:username])
    @users = (params[:type] == 'followers') ? @user.followers : @user.following
  end

  def hooks
    redirect_to "/" and return if !user_signed_in?
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks

    respond_to do |format|
      format.html { render 'hooks/index' }
      format.xml  { render 'hooks/index', :xml => @hooks }
      format.rss  { render 'hooks/index' }
    end
  end

  # GET /almost_ready
  def almost_ready
    if !user_signed_in?
      redirect_to root_url and return
    elsif !current_user.username.blank? and !current_user.email.blank?
      redirect_to "/settings/info" and return
    end

    respond_to do |format|
      if params[:user] and current_user.update_attributes(params[:user])
        format.html { redirect_to("/#{current_user.username}/list", :notice => 'User was successfully updated.') }
      else
        format.html
      end
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
        format.csv { render 'pages/export', :layout => false, :locals => {:pages => user.pages} }
      end
    else
      show_404
    end
  end

  def extras
    redirect_to "/" and return if !user_signed_in?
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

