require 'rails_helper'

describe Api::V1::DomainsController do
  render_views
  fixtures :domains

  describe 'GET index' do
    it 'returns a JSON array of domains' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['domains']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a domain' do
      get :show,
          format: :json,
          id: domains(:daringfireball).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('domains/domain')
    end
  end
end
