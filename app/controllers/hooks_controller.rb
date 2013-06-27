# encoding: utf-8
class HooksController < ApplicationController
  before_filter :authenticate_user!

  private

  def hook_params
    params.require(:hook).permit(:provider, :events).tap do |whitelisted|
      whitelisted[:params] = params[:hook][:params]
    end
  end

  public

  # GET /hooks/1
  # GET /hooks/1.xml
  def show
    @hook = Hook.fetch(params[:id])
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
    @hook = Hook.fetch(params[:id])
    if @hook.user != current_user
      redirect_to "/settings/hooks"
    end
  end

  # POST /hooks
  # POST /hooks.xml
  def create
    pms = hook_params
    if Authorization::PROVIDERS.include? pms[:provider]
      auth = Authorization.find_by_provider_and_uid(pms[:provider], pms[:params][:account])
      pms[:params].delete(:account)
      pms[:params] = pms[:params].to_json
      @hook = Hook.new(pms)
      @hook.authorization = auth
    else
      pms[:params] = pms[:params].to_json
      @hook = Hook.new(pms)
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
    @hook = Hook.fetch(params[:id])
    if @hook.user != current_user
      redirect_to "/settings/hooks"
    end

    respond_to do |format|
      if @hook.update_attributes(hook_params)
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
    @hook = Hook.fetch(params[:id])
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
