require 'rails_helper'

describe Api::V1::CommentsController do
  render_views
  fixtures :users, :pages, :posts, :comments

  describe 'GET index' do
    it 'returns a JSON array of comments' do
      get :index,
          format: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['comments']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    it 'returns a JSON object of a comment' do
      get :show,
          format: :json,
          id: comments(:single_mention).id

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('comments/comment')
    end
  end
end
