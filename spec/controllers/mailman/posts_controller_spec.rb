require 'rails_helper'

describe Mailman::PostsController, type: :api do
  fixtures :users

  let(:user) { users(:greg) }

  describe 'create' do
    shared_context 'a post creation endpoint' do |yn|
      it "creates a post#{yn.nil? ? '' : "marked as #{yn}"}" do
        db_count = user.posts.count

        post '//mailman.reading.am/api/posts',
             'recipient' => MailPipe.encode_mail_recipient('post', user, user),
             'stripped-text' => "Some text http://example.com #{yn}"

        expect(response.status).to eq(201)
        expect(user.posts.count).to eq(db_count + 1)
        expect(user.posts.last.yn).to eq(yn.nil? ? yn : yn == :yep), "Post's yep nope wasn't marked"
      end
    end

    it_behaves_like 'a post creation endpoint'
    it_behaves_like 'a post creation endpoint', :yep
    it_behaves_like 'a post creation endpoint', :nope
  end
end
