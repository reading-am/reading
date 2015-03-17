require 'rails_helper'
require 'support/shared_api_contexts'

describe Api::V1::CommentsController do
  render_views
  fixtures :users, :pages, :posts, :comments
  include_context 'api tokens'

  let(:default_schema) { 'comments/comment' }

  describe '#index' do
    let(:req_params) do
      [:get, :index, { access_token: ios_user_token.token }]
    end

    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe '#show' do
    let(:req_params) do
      [:get, :show, { access_token: ios_user_token.token,
                      id: comments(:single_mention).id }]
    end

    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
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
    it_behaves_like 'a response that renders JSON'
  end

  describe '#update' do
    let(:req_params) do
      [:patch, :update, { access_token: ios_user_token.token,
                          id: comments(:single_mention).id,
                          model: { body: 'This is a test comment' } }]
    end

    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe '#destroy' do
    let(:req_params) do
      [:delete, :destroy, { access_token: ios_user_token.token,
                            id: comments(:single_mention).id }]
    end

    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
  end
end
