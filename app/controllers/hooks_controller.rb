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
      redirect_to "/#{current_user.username}/hooks"
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
    @has_facebook = (auth = Authorization.find_by_user_id_and_provider(current_user.id, 'facebook') and auth.token)

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
      redirect_to "/#{current_user.username}/hooks"
    end
  end

  # POST /hooks
  # POST /hooks.xml
  def create
    redirect_to '/' if !logged_in?

    if ['twitter','facebook','instapaper','readability'].include? params[:hook][:provider]
      auth = Authorization.find_by_provider_and_uid(params[:hook][:provider], params[:hook][:params][:account])
      params[:hook][:params].delete(:account)
      params[:hook][:params] = params[:hook][:params].to_json
      @hook = Hook.new(params[:hook])
      @hook.authorization = auth
    else
      params[:hook][:params] = params[:hook][:params].to_json
      @hook = Hook.new(params[:hook])
    end
    @hook.user = current_user

    respond_to do |format|
      if @hook.errors.size == 0 and @hook.save
        format.html { redirect_to("/#{current_user.username}/hooks", :notice => 'Hook was successfully created.') }
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
      redirect_to "/#{current_user.username}/hooks"
    end

    respond_to do |format|
      if @hook.update_attributes(params[:hook])
        format.html { redirect_to("/#{current_user.username}/hooks", :notice => 'Hook was successfully updated.') }
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
      redirect_to "/#{current_user.username}/list"
    end
    @hook.destroy

    respond_to do |format|
      format.html { redirect_to("/#{current_user.username}/hooks") }
      format.xml  { head :ok }
    end
  end

end
