require 'rails_helper'
require 'support/shared_api_contexts'

describe Api::V1::CommentsController do
  render_views
  fixtures :users, :pages, :posts, :comments
  include_context 'api tokens'

  describe 'GET index' do
    it 'returns a JSON array of comments' do
      get :index,
          format: :json,
          access_token: ios_user_token.token

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)['comments']
      expect(json).not_to be_empty
    end
  end

  describe 'GET show' do
    before do
      get :show,
          format: :json,
          id: comments(:single_mention).id,
          access_token: ios_user_token.token
    end

    it_behaves_like 'a successful request'
    it_behaves_like 'a show request', 'comments/comment'
  end
end
