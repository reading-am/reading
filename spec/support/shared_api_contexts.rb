require 'rails_helper'

shared_context "api tokens" do
  fixtures :users, :oauth_applications
  let(:ios_client_token) { Doorkeeper::AccessToken.create! application_id: oauth_applications(:ios).id,
                                                           scopes: "register one_time_token" }
  let(:third_party_client_token) { Doorkeeper::AccessToken.create! application_id: oauth_applications(:third_party).id }

  let(:ios_user_token) { Doorkeeper::AccessToken.create! resource_owner_id: users(:greg).id,
                                                         application_id: oauth_applications(:ios).id,
                                                         scopes: "public write" }
  let(:third_party_user_token) { Doorkeeper::AccessToken.create! resource_owner_id: users(:greg).id,
                                                                 application_id: oauth_applications(:third_party).id }
end

shared_context 'a response that renders JSON' do |schema|
  it 'returns the specified item' do
    send(req_params[0], req_params[1], **req_params[2])
    expect(response).to match_response_schema(schema)
  end
end

shared_context 'a successful request' do
  it 'returns an successful (2xx) status code' do
    send(req_params[0], req_params[1], **req_params[2])
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
