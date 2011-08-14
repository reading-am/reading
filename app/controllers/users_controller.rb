class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    if params[:username]
      @user = User.find_by_username(params[:username])
    else
      @user = User.find(params[:id])
    end
    @posts = @user.feed
    respond_to do |format|
      format.html { render 'posts/index' }
      format.xml  { render 'posts/index', :xml => @posts }
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

  # GET /users/1/edit
  def edit
    if params[:username]
      @user = User.find_by_username(params[:username])
    else
      @user = User.find(params[:id])
    end
    if @user != current_user
      redirect_to "/#{@user.username}"
    end
    
    if params[:user] and @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
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

  # GET /pick_a_url
  def pick_a_url
    if !logged_in?
      redirect_to root_url
    elsif current_user.username
      redirect_to "/#{current_user.username}/settings"
    end

    respond_to do |format|
      if params[:user] and current_user.update_attributes(params[:user])
        format.html { redirect_to("/#{current_user.username}", :notice => 'User was successfully updated.') }
      else
        format.html
      end
    end
  end
end

