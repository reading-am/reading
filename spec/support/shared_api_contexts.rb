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

# via: http://www.bignerdranch.com/blog/using-rspec-shared-contexts-ensure-api-consistency/

shared_context 'a failed create' do
  it 'returns an unprocessable entity (422) status code' do
    expect(response.status).to eq(422)
  end
end

shared_context 'a response with nested errors' do
  it 'returns the error messages' do
    json = JSON.parse(response.body)['errors']
    expect(json['error']).to eq(message)
  end
end

shared_context 'a response with errors' do
  it 'returns the error messages' do
    json = JSON.parse(response.body)
    expect(json['error']).to eq(message)
  end
end

shared_context 'a show request with a root' do |root|
  it 'returns the specified item' do
    json = JSON.parse(response.body)[root]
    expect(json['id']).to eq(id)
  end
end

shared_context 'a show request' do |schema|
  it 'returns the specified item' do
    expect(response).to match_response_schema(schema)
  end
end

shared_context 'a successful request' do
  it 'returns an OK (200) status code' do
    expect(response).to have_http_status(:success)
  end
end
