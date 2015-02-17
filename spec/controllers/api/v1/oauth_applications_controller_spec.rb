require 'rails_helper'

describe Api::V1::OauthApplicationsController do
  render_views
  fixtures :oauth_applications

  describe 'GET index' do
    it 'returns a JSON array of oauth applications' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['oauth_applications']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of an oauth application' do
      get :show,
          format: :json,
          id: oauth_applications(:ios).uid

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('oauth_applications/oauth_application')
    end
  end
end
