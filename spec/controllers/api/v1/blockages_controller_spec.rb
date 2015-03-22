require 'rails_helper'

describe Api::V1::BlockagesController, type: :api do
  include_context 'api defaults'
  fixtures :users, :blockages

  let(:resource) { users(:howard) }
  let(:list_endpoint) { "#{url_base}/users/#{users(:greg).id}/blocking" }

  describe 'index' do
    it_behaves_like 'a restricted endpoint', 'public'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end

  describe 'create' do
    let(:method) { :post }
    let(:params) { { model: { blocked_id: resource.id } } }
    it_behaves_like 'a restricted endpoint', 'write'
    it_behaves_like 'a successful request'
    it_behaves_like 'a response that renders JSON'
  end
end
