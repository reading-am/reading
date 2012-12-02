# encoding: utf-8
class HooksController < ApplicationController
  before_filter :authenticate_user!

  # GET /hooks/1
  # GET /hooks/1.xml
  def show
    @hook = Hook.find(params[:id])
    if @hook.user != current_user
      redirect_to "/settings/hooks"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @hook }
    end
  end

  # GET /hooks/new
  # GET /hooks/new.xml
  def new
    @hook = Hook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @hook }
    end
  end

  # GET /hooks/1/edit
  def edit
    @hook = Hook.find(params[:id])
    if !user_signed_in?
      redirect_to "/"
    elsif @hook.user != current_user
      redirect_to "/settings/hooks"
    end
  end

  # POST /hooks
  # POST /hooks.xml
  def create
    if Authorization::PROVIDERS.include? params[:hook][:provider]
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
        format.html { redirect_to("/settings/hooks", :notice => 'Hook was successfully created.') }
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
    if @hook.user != current_user
      redirect_to "/settings/hooks"
    end

    respond_to do |format|
      if @hook.update_attributes(params[:hook])
        format.html { redirect_to("/settings/hooks", :notice => 'Hook was successfully updated.') }
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
    if @hook.user != current_user
      redirect_to "/#{current_user.username}/list"
    end
    @hook.destroy

    respond_to do |format|
      format.html { redirect_to("/settings/hooks") }
      format.xml  { head :ok }
    end
  end

end
