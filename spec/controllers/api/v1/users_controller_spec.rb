require 'rails_helper'

describe Api::V1::UsersController, type: :api do
  include_context 'api defaults'
  fixtures :users, :relationships

  let(:resource) { users(:greg) }

  describe '/users' do
    describe 'show' do
      let(:endpoint) { detail_endpoint }
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    describe 'update' do
      let(:method) { :patch }
      let(:endpoint) { detail_endpoint }
      let(:params) { { first_name: 'John',
                       last_name: 'Smith',
                       bio: 'A new bio',
                       link: 'http://example.com',
                       location: 'Boston, MA' } }
      it_behaves_like 'a restricted endpoint', 'admin'
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
    let(:detail_endpoint) { "#{url_base}/user" }

    describe 'show' do
      let(:endpoint) { detail_endpoint }
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    describe 'update' do
      let(:method) { :patch }
      let(:endpoint) { detail_endpoint }
      let(:params) { { first_name: 'John',
                       last_name: 'Smith',
                       bio: 'A new bio',
                       link: 'http://example.com',
                       location: 'Boston, MA' } }
      it_behaves_like 'a restricted endpoint', 'write'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end
  end

  describe '/pages' do
    let(:url_base) { "#{super()}/pages"}

    describe '/:id/users' do
      let(:list_endpoint) { "#{url_base}/#{pages(:daringfireball).id}/users" }

      describe 'index' do
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end
    end
  end
end
