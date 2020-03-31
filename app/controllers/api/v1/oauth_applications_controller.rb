# encoding: utf-8
module Api::V1
  class OauthApplicationsController < ApiController

    def index
      render locals: { oauth_applications: OauthApplications.index(params) }
    end
    require_scope_for :index, :public
    
    def show
      render locals: { oauth_application: Doorkeeper::Application.find_by_uid(params[:id]) }
    end
    require_scope_for :show, :public

    def create
      app = Doorkeeper::Application.new(app_params)
      app.owner = current_user
      app.save

      render locals: { oauth_application: app }
    end
    require_scope_for :create, :write

    def update
      app = Doorkeeper::Application.find_by(uid: params[:id], owner: current_user)
      app.update_attributes(app_params)
      render :create, locals: { oauth_application: app }
    end
    require_scope_for :update, :write

    def destroy
      app = Doorkeeper::Application.by_uid(params[:id])

      app.destroy if current_user == app.owner

      respond_to do |format|
        status = app.destroyed? ? :ok : :forbidden
        format.json { render_json status }
      end
    end
    require_scope_for :destroy, :write

    private

    def app_params
      params.require(:model).permit(:name,
                                    :redirect_uri,
                                    :description,
                                    :website,
                                    :app_store_url,
                                    :play_store_url)
    end
  end
end
