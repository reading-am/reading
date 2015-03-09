# encoding: utf-8
module Api::V1
  class OauthAccessTokensController < ApiController

    add_transaction_tracer :index
    require_scope_for :index, :public
    def index
      render locals: { oauth_access_tokens: OauthAccessTokens.index(params) }
    end

    add_transaction_tracer :show
    require_scope_for :show, :public
    def show
      render locals: { oauth_access_token: Doorkeeper::AccessToken.find(params[:id]) }
    end

    add_transaction_tracer :destroy
    require_scope_for :destroy, :write
    def destroy
      token = Doorkeeper::AccessToken.by_token(params[:id]) || Doorkeeper::AccessToken.by_refresh_token(params[:id])

      if current_user == token.user
        if token.revoked?
          status = :ok
        else
          token.revoke
          status = token.revoked? ? :ok : :internal_server_error
        end
      else
        status = :forbidden
      end

      respond_to do |format|
        format.json { render_json status }
      end
    end
  end
end
