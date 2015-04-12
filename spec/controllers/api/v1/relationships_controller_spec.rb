require 'rails_helper'

describe Api::V1::RelationshipsController, type: :api do
  include_context 'api defaults'
  fixtures :users, :relationships

  let(:resource) { users(:greg) }

  describe '/users' do

    describe '/followers' do
      let(:endpoint) { "#{detail_endpoint}/followers" }
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    describe '/following' do
      let(:endpoint) { "#{detail_endpoint}/following" }
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end
  end

  describe '/user' do
    let(:detail_endpoint) { "#{url_base}/user" }

    describe '/followers' do
      let(:endpoint) { "#{detail_endpoint}/followers" }
      it_behaves_like 'a restricted endpoint', 'public'
      it_behaves_like 'a successful request'
      it_behaves_like 'a response that renders JSON'
    end

    describe '/following' do
      let(:endpoint) { "#{detail_endpoint}/following" }

      describe 'index' do
        it_behaves_like 'a restricted endpoint', 'public'
        it_behaves_like 'a successful request'
        it_behaves_like 'a response that renders JSON'
      end

      describe 'create' do
        let(:method) { :post }
        let(:params) { { model: { blocked_id: users(:howard).id } } }
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
    end
  end
end
