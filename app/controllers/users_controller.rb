# encoding: utf-8
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    if api?
      if params[:page_id]
        @page = Page.find(params[:page_id])
        @users = User.who_posted_to(@page)
        # this is disabled until we get more users on the site
        # :following => @post.user.following_who_posted_to(@post.page).collect { |user| user.simple_obj }
      end
    else
      @users = User.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.json { render :json => {
        :meta => {
          :status => 200,
          :msg => 'OK'
        },
        :response => {
          :users => @users.collect { |user|
            obj = user.simple_obj
            cur_post = user.posts.where('page_id = ?', @page.id).last
            before =  user.posts.where('id < ?', cur_post.id).first
            after = user.posts.where('id > ?', cur_post.id).last
            obj[:posts] = {
              :before => before.blank? ? nil : before.simple_obj,
              :after => after.blank? ? nil : after.simple_obj
            }
            obj
          }
        }
      }, :callback => params[:callback] }
    end
  end

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

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def settings
    redirect_to logged_in? ? "/settings/info" : "/"
  end

  # GET /users/1/edit
  def edit
    redirect_to "/" if !logged_in?
    @user = current_user
    if params[:user] and @user.update_attributes(params[:user])
      redirect_to("/settings/info", :notice => 'User was successfully updated.')
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

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
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def followingers
    @user = User.find_by_username(params[:username])
    @users = (params[:type] == 'followers') ? @user.followers : @user.following
  end

  def hooks
    redirect_to "/" if !logged_in?
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
    redirect_to "/" if !logged_in?
    @user = current_user
  end
end

