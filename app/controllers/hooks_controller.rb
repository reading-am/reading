class HooksController < ApplicationController
  # GET /hooks
  # GET /hooks.xml
  def index
    @hooks = Hook.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @hooks }
    end
  end

  # GET /hooks/1
  # GET /hooks/1.xml
  def show
    @hook = Hook.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @hook.user != current_user
      redirect_to "/#{current_user.username}/settings"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @hook }
    end
  end

  # GET /hooks/new
  # GET /hooks/new.xml
  def new
    if !logged_in?
      redirect_to "/"
    end
    @hook = Hook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @hook }
    end
  end

  # GET /hooks/1/edit
  def edit
    @hook = Hook.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @hook.user != current_user
      redirect_to "/#{current_user.username}/settings"
    end
  end

  # POST /hooks
  # POST /hooks.xml
  def create
    if !logged_in?
      redirect_to '/'
    end
    @hook = Hook.new(params[:hook])
    @hook.user = current_user

    respond_to do |format|
      if @hook.save
        format.html { redirect_to(@hook, :notice => 'Hook was successfully created.') }
        format.xml  { render :xml => @hook, :status => :created, :location => @hook }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @hook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /hooks/1
  # PUT /hooks/1.xml
  def update
    @hook = Hook.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @hook.user != current_user
      redirect_to "/#{current_user.username}/settings"
    end

    respond_to do |format|
      if @hook.update_attributes(params[:hook])
        format.html { redirect_to(@hook, :notice => 'Hook was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @hook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /hooks/1
  # DELETE /hooks/1.xml
  def destroy
    @hook = Hook.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @hook.user != current_user
      redirect_to "/#{current_user.username}"
    end
    @hook.destroy

    respond_to do |format|
      format.html { redirect_to(hooks_url) }
      format.xml  { head :ok }
    end
  end

end
