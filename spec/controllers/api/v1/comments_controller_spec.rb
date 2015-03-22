require 'rails_helper'

describe Api::V1::CommentsController, type: :api do
  include_context 'api defaults'
  fixtures :pages, :comments

  let(:resource) { comments(:single_mention) }

  describe 'index' do
    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe 'show' do
    let(:endpoint) { detail_endpoint }
    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe 'create' do
    let(:method) { :post }
    let(:params) do
      { model: { body: 'This is a test comment',
                 page_id: pages(:daringfireball).id } }
    end
    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe 'update' do
    let(:method) { :patch }
    let(:endpoint) { detail_endpoint }
    let(:params) { { model: { body: 'This is an updated comment' } } }
    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe 'delete' do
    let(:method) { :delete }
    let(:endpoint) { detail_endpoint }
    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
  end

  describe 'stats' do
    let(:schema) { 'shared/stats' }
    let(:endpoint) { "#{list_endpoint}/stats" }
    it_behaves_like 'a restricted endpoint', 'admin'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end
end
