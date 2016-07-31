# encoding: utf-8
class AuthorizationsController < ApplicationController
  before_action :authenticate_user!, :except => [:loading]

  def places
    @auth = Authorization.find_by_provider_and_uid(params[:provider], params[:uid])

    if @auth.user == current_user
      case @auth.provider
      when 'tumblr'
        places = @auth.api.user_info.response.user.blogs
      when 'evernote'
        places = @auth.api.listNotebooks @auth.token
      when 'tssignals'
        places = @auth.api.rooms
      when 'slack'
        places = @auth.api.channels_list.channels
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
    if @authorization.user != current_user
      redirect_to "/#{current_user.username}/list"
    end
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to("/settings/info") }
      format.xml  { head :ok }
    end
  end

  def loading
    render :layout => false
  end
end
