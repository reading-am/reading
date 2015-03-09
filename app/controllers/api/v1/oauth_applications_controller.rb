# encoding: utf-8
module Api::V1
  class OauthApplicationsController < ApiController

    private

    def app_params
      params.require(:model).permit(:name,
                                    :redirect_uri,
                                    :description,
                                    :website,
                                    :app_store_url,
                                    :play_store_url
                                   )
    end

    public

    def index
      render locals: { oauth_applications: OauthApplications.index(params) }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :index
    add_transaction_tracer :index

    def show
      render locals: { oauth_application: Doorkeeper::Application.find_by_uid(params[:id]) }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :show
    add_transaction_tracer :show

    def create
      app = Doorkeeper::Application.new(app_params)
      app.owner = current_user
      app.save

      render locals: { oauth_application: app }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :create
    add_transaction_tracer :create

    def update
      app = Doorkeeper::Application.by_uid_and_owner(params[:id], current_user)
      app.update_attributes(app_params)
      render :create, locals: { oauth_application: app }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :update
    add_transaction_tracer :update

    def destroy
      app = Doorkeeper::Application.by_uid(params[:id])

      app.destroy if current_user == app.owner

      respond_to do |format|
        status = app.destroyed? ? :ok : :forbidden
        format.json { render_json status }
      end
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :destroy
    add_transaction_tracer :destroy

  end
end
