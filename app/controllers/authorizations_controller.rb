# encoding: utf-8
class AuthorizationsController < ApplicationController
  # PUT /authorizations/1
  # PUT /authorizations/1.xml
  def update
    @auth = Authorization.find_by_provider_and_uid(params[:provider], params[:uid])

    if allowed = @auth.user == current_user and !params[:authorization].nil?
      @auth.attributes = params[:authorization]
    end

    respond_to do |format|
      if allowed and @auth.save
        format.html { redirect_to(@auth, :notice => 'Authorization was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {}
        }, :callback => params[:callback] }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @auth.errors, :status => :unprocessable_entity }
        if !allowed # TODO clean up this auth hack. Ugh.
          format.json { render :json => {:meta => {:status => 403, :msg => "Forbidden"}}, :callback => params[:callback] }
        else
          format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request #{@auth.errors.to_yaml}"}}, :callback => params[:callback] }
        end
      end
    end
  end

  def places
    @auth = Authorization.find_by_provider_and_uid(params[:provider], params[:uid])

    if allowed = @auth.user == current_user
      case @auth.provider
      when 'tumblr'
        places = @auth.api.user_info.response.user.blogs
      when 'evernote'
        places = @auth.api.listNotebooks @auth.token
      when 'tssignals'
        places = @auth.api.rooms
      when 'kippt'
        places = @auth.api.lists.all(limit: 0) # forces all to be listed rather than paginated
      end
    end
    respond_to do |format|
      if places.nil?
        format.json { render :json => {:meta => {:status => 400, :msg => "Bad Request"}}, :callback => params[:callback] }
      else
        format.json { render :json => {
          :meta => {
            :status => 200,
            :msg => 'OK'
          },
          :response => {:places => places}
        }, :callback => params[:callback] }
      end
    end
  end

  # DELETE /authorizations/1
  # DELETE /authorizations/1.xml
  def destroy
    @authorization = Authorization.find(params[:id])
    if !logged_in?
      redirect_to "/"
    elsif @authorization.user != current_user
      redirect_to "/#{current_user.username}/list"
    end
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to("/settings/info") }
      format.xml  { head :ok }
    end
  end

  def loading
    render "loading", :layout => false
  end
end
