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
      render locals: { apps: OauthApplications.index(params) }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :index
    add_transaction_tracer :index

    def show
      render locals: { app: Doorkeeper::Application.find_by_uid(params[:id]) }
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :show
    add_transaction_tracer :show

    def create
      app = Doorkeeper::Application.new(app_params)
      app.owner = current_user

      respond_to do |format|
        if app.save
          obj = app.simple_obj
          obj[:consumer_secret] = app.secret
          format.json { render_json({oauth_application: obj}, :created) }
        else
          status = app.owner.blank? ? :forbidden : :bad_request
          format.json { render_json status }
        end
      end
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :create
    add_transaction_tracer :create

    def update
      app = Doorkeeper::Application.by_uid(params[:id])

      respond_to do |format|
        if current_user == app.owner
          if app.update_attributes(app_params)
            obj = app.simple_obj
            obj[:consumer_secret] = app.secret
            format.json { render_json({oauth_application: obj}, :ok) }
          else
            format.json { render_json :bad_request }
          end
        else
          format.json { render_json :forbidden }
        end
      end
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
