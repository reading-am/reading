require 'rails_helper'

describe Api::V1::PostsController do
  render_views
  fixtures :users, :posts

  describe 'GET index' do
    it 'returns a JSON array of posts' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['posts']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a post' do
      get :show,
          format: :json,
          id: posts(:one).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('posts/post')
    end
  end
end
