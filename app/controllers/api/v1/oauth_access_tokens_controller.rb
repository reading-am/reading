# encoding: utf-8
module Api::V1
  class OauthAccessTokensController < ApiController

    def index
      render locals: { oauth_access_tokens: OauthAccessTokens.index(params) }
    end
    require_scope_for :index, :public
    
    def show
      render locals: { oauth_access_token: Doorkeeper::AccessToken.find(params[:id]) }
    end
    require_scope_for :show, :public

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
    require_scope_for :destroy, :write
  end
end
