require 'rails_helper'

shared_context 'api defaults' do
  fixtures :oauth_access_tokens
  let(:token) { oauth_access_tokens(:ios_user_token) }
  let(:method) { :get }
  let(:params) { {} }
  let(:list_endpoint) { "#{url_base}/#{resource.class.name.downcase.pluralize}" }
  let(:detail_endpoint) { "#{list_endpoint}/#{resource.id}" }
  let(:endpoint) { list_endpoint }
  let(:schema) do
    name = resource.class.name.downcase
    "#{name.pluralize}/#{name}"
  end
end

shared_context 'a response that renders JSON' do |s|
  it 'returns the specified item' do
    set_auth_header
    request endpoint, method: method, params: params
    expect(response).to match_response_schema(s || schema)
  end
end

shared_context 'a successful request' do
  it 'returns a successful (2xx) status code' do
    set_auth_header
    request endpoint, method: method, params: params
    expect("#{response.status}"[0]).to eq('2'), "Expected 2xx got #{response.status}"
  end
end

shared_context 'a restricted endpoint' do |scope|
  it 'returns a FORBIDDEN (403) status code' do
    set_auth_header
    scopes = token.scopes.to_a
    scopes.delete scope
    token.update scopes: scopes.join(' ')
    request endpoint, method: method, params: params
    expect(response.status).to eq(403)
  end
end
