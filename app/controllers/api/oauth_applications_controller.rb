# encoding: utf-8
class Api::OauthApplicationsController < Api::APIController

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
    respond_to do |format|
      format.json do
        render_json oauth_applications: Api::OauthApplications.index(params).map { |app| app.simple_obj }
      end
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :index
  add_transaction_tracer :index

  def show
    @app = Doorkeeper::Application.find_by_uid(params[:id])

    respond_to do |format|
      format.json { render_json oauth_application: @app.simple_obj }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :show
  add_transaction_tracer :show

  def create
    @user = params[:token] ? User.find_by_token(params[:token]) : current_user
    @app = Doorkeeper::Application.new(app_params)
    @app.owner = @user

    respond_to do |format|
      if @app.save
        obj = @app.simple_obj
        obj[:consumer_secret] = @app.secret
        format.json { render_json({oauth_application: obj}, :created) }
      else
        status = @app.owner.blank? ? :forbidden : :bad_request
        format.json { render_json status }
      end
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :create
  add_transaction_tracer :create

  def update
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :update
  add_transaction_tracer :update

  def destroy
    @user = params[:token] ? User.find_by_token(params[:token]) : current_user
    @app = Doorkeeper::Application.by_uid(params[:id])

    @app.destroy if @user == @app.owner

    respond_to do |format|
      status = @app.destroyed? ? :ok : :forbidden
      format.json { render_json status }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :destroy
  add_transaction_tracer :destroy

end
