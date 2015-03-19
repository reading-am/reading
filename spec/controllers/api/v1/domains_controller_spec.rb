require 'rails_helper'

describe Api::V1::DomainsController do
  render_views
  fixtures :oauth_access_tokens, :domains

  let(:token) { oauth_access_tokens(:ios_user_token) }
  let(:schema) { 'domains/domain' }
  let(:resource) { domains(:daringfireball) }

  it_behaves_like 'an index'
  it_behaves_like 'a show'
  it_behaves_like 'stats'
end
