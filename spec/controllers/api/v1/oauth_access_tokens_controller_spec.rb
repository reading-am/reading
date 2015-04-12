require 'rails_helper'

describe Api::V1::OauthAccessTokensController, type: :api do
  include_context 'api defaults'
  fixtures :oauth_access_tokens

  let(:resource) { oauth_access_tokens(:ios_user_token) }

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
