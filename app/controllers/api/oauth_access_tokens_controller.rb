# encoding: utf-8
class Api::OauthAccessTokensController < Api::APIController

  private

  def token_params
    params.require(:model).permit(:yn)
  end

  public

  def index
    respond_to do |format|
      format.json do
        render_json oauth_access_tokens: Api::OauthAccessTokens.index(params).map { |token| token.simple_obj }
      end
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :index
  add_transaction_tracer :index

  def show
    @token = Doorkeeper::AccessToken.find(params[:id])

    respond_to do |format|
      format.json { render_json oauth_access_token: @token.simple_obj }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :show
  add_transaction_tracer :show

  def create
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :create
  add_transaction_tracer :create

  def update
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :update
  add_transaction_tracer :update

  def destroy
    @user = params[:token] ? User.find_by_token(params[:token]) : current_user
    @token = Doorkeeper::AccessToken.by_token(params[:id]) || Doorkeeper::AccessToken.by_refresh_token(params[:id])

    if @user == @token.user
      if @token.revoked?
        status = :ok
      else
        @token.revoke
        status = @token.revoked? ? :ok : :internal_server_error
      end
    else
      status = :forbidden
    end

    respond_to do |format|
      format.json { render_json status }
    end
  end
  # before_action -> { doorkeeper_authorize! :public }, only: :destroy
  add_transaction_tracer :destroy

end
