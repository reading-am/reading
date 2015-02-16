require 'rails_helper'

describe Api::V1::PostsController do
  render_views
  fixtures :users, :posts

  let(:token) { Doorkeeper::AccessToken.create! resource_owner_id: users(:greg).id }

  describe 'GET index' do
    it 'renders the index template' do
      get :index,
          format: :json,
          access_token: token.token

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['posts']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'renders the show template' do
      get :show,
          format: :json,
          access_token: token.token,
          id: posts(:one).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema("posts/post")
    end
  end
end
