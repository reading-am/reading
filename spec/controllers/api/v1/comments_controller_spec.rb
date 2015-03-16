require 'rails_helper'
require 'support/shared_api_contexts'

describe Api::V1::CommentsController do
  render_views
  fixtures :users, :pages, :posts, :comments
  include_context 'api tokens'

  describe '#index' do
    let(:req_params) do
      [:get, :index, { access_token: ios_user_token.token }]
    end

    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON', 'comments/comment'
  end

  describe '#show' do
    let(:req_params) do
      [:get, :show, { id: comments(:single_mention).id,
                      access_token: ios_user_token.token }]
    end

    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON', 'comments/comment'
  end

  describe '#create' do
    let(:req_params) do
      [:post, :create, { access_token: ios_user_token.token,
                         model: {
                           body: 'This is a test comment',
                           page_id: pages(:daringfireball).id
                         } }]
    end

    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON', 'comments/comment'
  end
end
