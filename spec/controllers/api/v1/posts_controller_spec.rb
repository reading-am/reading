require 'rails_helper'

describe Api::V1::PostsController, type: :api do
  include_context 'api defaults'
  fixtures :users, :relationships, :domains, :pages, :posts

  let(:resource) { posts(:one) }

  shared_context 'a medium filter' do
    Page::MEDIUMS.each do |medium|
      describe "/#{medium}" do
        let(:list_endpoint) { "#{super()}/#{medium}" }
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end
    end
  end

  describe '/posts' do

    describe 'index' do
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    it_behaves_like 'a medium filter'

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
      let(:params) { { model: { yn: true } } }
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

  describe '/users/:id/posts' do
    let(:list_endpoint) { "#{url_base}/users/#{users(:greg).id}/posts" }

    describe 'index' do
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    it_behaves_like 'a medium filter'
  end

  describe '/users/:id/following/posts' do
    let(:list_endpoint) { "#{url_base}/users/#{users(:max).id}/following/posts" }

    describe 'index' do
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    it_behaves_like 'a medium filter'
  end

  describe '/domains/:id/posts' do
    let(:list_endpoint) { "#{url_base}/domains/#{domains(:daringfireball).id}/posts" }

    describe 'index' do
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    it_behaves_like 'a medium filter'
  end

  describe '/pages/:id/posts' do
    let(:list_endpoint) { "#{url_base}/pages/#{pages(:daringfireball).id}/posts" }

    describe 'index' do
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end
  end
end
