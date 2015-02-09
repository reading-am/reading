# encoding: utf-8
module Api::V1
  class OauthAccessTokensController < ApiController

    private

    def token_params
      params.require(:model).permit(:yn)
    end

    public

    def index
      @tokens = OauthAccessTokens.index(params)
      render
    end
    # before_action -> { doorkeeper_authorize! :public }, only: :index
    add_transaction_tracer :index

    def show
      @token = Doorkeeper::AccessToken.find(params[:id])
      render
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
      @token = Doorkeeper::AccessToken.by_token(params[:id]) || Doorkeeper::AccessToken.by_refresh_token(params[:id])

      if current_user == @token.user
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
end
