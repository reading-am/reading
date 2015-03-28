require 'rails_helper'

describe Api::V1::PagesController, type: :api do
  include_context 'api defaults'
  fixtures :users, :domains, :pages

  let(:resource) { pages(:daringfireball) }

  describe '/pages' do

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

    describe 'update' do
      let(:method) { :patch }
      let(:endpoint) { detail_endpoint }
      let(:params) { { model: { body: 'This is an updated comment' } } }
      it_behaves_like 'a restricted endpoint', 'write'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    describe 'stats' do
      let(:schema) { 'shared/stats' }
      let(:endpoint) { "#{list_endpoint}/stats" }
      it_behaves_like 'a restricted endpoint', 'admin'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end
  end

  describe '/user' do
    let(:url_base) { "#{super()}/user"}

    describe '/pages' do
      let(:list_endpoint) { "#{url_base}/pages" }

      describe 'index' do
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end
    end
  end

  describe '/users' do
    let(:url_base) { "#{super()}/users"}

    describe '/:id/pages' do
      let(:list_endpoint) { "#{url_base}/#{users(:greg).id}/pages" }

      describe 'index' do
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end
    end
  end

  describe '/domains' do
    let(:url_base) { "#{super()}/domains"}

    describe '/:id/pages' do
      let(:list_endpoint) { "#{url_base}/#{domains(:daringfireball).id}/pages" }

      describe 'index' do
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end
    end
  end
end
