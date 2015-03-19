require 'rails_helper'

shared_context 'a response that renders JSON' do |s|
  it 'returns the specified item' do
    send(req_params[0], req_params[1], **req_params[2])
    expect(response).to match_response_schema(s || schema)
  end
end

shared_context 'a successful request' do
  it 'returns an successful (2xx) status code' do
    params = req_params[2] || {}
    send(req_params[0], req_params[1], **params)
    expect(response).to have_http_status(:success)
  end
end

shared_context 'a restricted endpoint' do |scope|
  it 'returns an FORBIDDEN (403) status code' do
    token = Doorkeeper::AccessToken.find_by_token(req_params[2][:access_token])
    scopes = token.scopes.to_a
    scopes.delete scope
    token.update scopes: scopes.join(' ')
    send(req_params[0], req_params[1], **req_params[2])
    expect(response).to have_http_status(:forbidden)
  end
end

shared_context 'an index' do
  let(:req_params) do
    [:get, :index, { access_token: token.token }]
  end

  it_behaves_like 'a restricted endpoint', 'public'
  it_behaves_like 'a successful request'
  it_behaves_like 'a response that renders JSON'
end

shared_context 'a show' do
  let(:req_params) do
    [:get, :show, { access_token: token.token,
                    id: resource.id }]
  end

  it_behaves_like 'a restricted endpoint', 'public'
  it_behaves_like 'a successful request'
  it_behaves_like 'a response that renders JSON'
end

shared_context 'a create' do
  let(:req_params) do
    [:post, :create, { access_token: token.token,
                       model: create_params }]
  end

  it_behaves_like 'a restricted endpoint', 'write'
  it_behaves_like 'a successful request'
  it_behaves_like 'a response that renders JSON'
end

shared_context 'an update' do
  let(:req_params) do
    [:patch, :update, { access_token: token.token,
                        id: resource,
                        model: update_params }]
  end

  it_behaves_like 'a restricted endpoint', 'write'
  it_behaves_like 'a successful request'
  it_behaves_like 'a response that renders JSON'
end

shared_context 'a delete' do
  let(:req_params) do
    [:delete, :destroy, { access_token: token.token,
                          id: resource }]
  end

  it_behaves_like 'a restricted endpoint', 'write'
  it_behaves_like 'a successful request'
end

shared_context 'stats' do
  let(:req_params) do
    [:get, :stats, { access_token: token.token }]
  end

  it_behaves_like 'a restricted endpoint', 'admin'
  it_behaves_like 'a successful request'
  it_behaves_like 'a response that renders JSON', 'shared/stats'
end
