require 'rails_helper'

describe Api::V1::OauthAccessTokensController do
  render_views
  fixtures :oauth_access_tokens

  let(:token) { oauth_access_tokens(:ios_user_token) }
  let(:schema) { 'oauth_access_tokens/oauth_access_token' }
  let(:resource) { oauth_access_tokens(:ios_user_token) }

  it_behaves_like 'an index'
  it_behaves_like 'a show'
end
