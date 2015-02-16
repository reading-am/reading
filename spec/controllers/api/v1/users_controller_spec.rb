require 'rails_helper'

describe Api::V1::UsersController do
  render_views
  fixtures :users

  describe 'GET index' do
    it 'returns a JSON array of users' do
      get :index,
          format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a user' do
      get :show,
          format: :json,
          id: users(:greg).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('users/user')
    end
  end
end
