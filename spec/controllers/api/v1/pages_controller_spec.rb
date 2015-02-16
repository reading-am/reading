require 'rails_helper'

describe Api::V1::PagesController do
  render_views
  fixtures :pages

  describe 'GET index' do
    it 'returns a JSON array of pages' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['pages']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a page' do
      get :show,
          format: :json,
          id: pages(:daringfireball).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('pages/page')
    end
  end
end
