require 'rails_helper'

describe Api::V1::OauthAccessTokensController do
  render_views
  fixtures :oauth_applications, :oauth_access_tokens

  describe 'GET index' do
    it 'returns a JSON array of oauth access tokens' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['oauth_access_tokens']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a oauth access token' do
      get :show,
          format: :json,
          id: oauth_access_tokens(:one).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('oauth_access_tokens/oauth_access_token')
    end
  end
end
