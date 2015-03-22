require 'rails_helper'

describe Api::V1::OauthApplicationsController, type: :api do
  include_context 'api defaults'
  fixtures :oauth_applications

  let(:resource) { oauth_applications(:ios) }
  let(:detail_endpoint) { "#{list_endpoint}/#{resource.uid}" }

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
end
