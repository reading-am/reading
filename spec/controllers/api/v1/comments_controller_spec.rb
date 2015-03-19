require 'rails_helper'
require 'support/shared_api_contexts'

describe Api::V1::CommentsController do
  render_views
  fixtures :oauth_access_tokens, :pages, :comments

  let(:token) { oauth_access_tokens(:ios_user_token) }
  let(:schema) { 'comments/comment' }
  let(:resource) { comments(:single_mention) }

  it_behaves_like 'an index'
  it_behaves_like 'a show'
  it_behaves_like 'a delete'

  let(:create_params) do
    { body: 'This is a test comment',
      page_id: pages(:daringfireball).id }
  end
  it_behaves_like 'a create'

  let(:update_params) { { body: 'This is an updated comment' } }
  it_behaves_like 'an update'

  it_behaves_like 'stats'
end
