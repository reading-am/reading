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
        @posts = @user.posts.paginate(:page => params[:page])
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
    redirect_to logged_in? ? "/settings/info" : "/"
  end

  # GET /users/1/edit
  def edit
    redirect_to "/" and return if !logged_in?
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

  def followingers
    @user = User.find_by_username(params[:username])
    @users = (params[:type] == 'followers') ? @user.followers : @user.following
  end

  def hooks
    redirect_to "/" and return if !logged_in?
    @user = current_user
    @new_hook = Hook.new
    @hooks = @user.hooks

    respond_to do |format|
      format.html { render 'hooks/index' }
      format.xml  { render 'hooks/index', :xml => @hooks }
      format.rss  { render 'hooks/index' }
    end
  end

  # GET /pick_a_url
  def pick_a_url
    if !logged_in?
      redirect_to root_url and return
    elsif current_user.username
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
    redirect_to "/" and return if !logged_in?
    @user = current_user
  end

  def recommended
    @users = User.limit(10)
    render :find_people
  end
end

