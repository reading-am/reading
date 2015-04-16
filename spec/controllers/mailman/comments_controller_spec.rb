require 'rails_helper'

describe Mailman::CommentsController, type: :api do
  fixtures :users, :comments, :domains, :pages

  let(:user) { users(:greg) }
  let(:comment) { comments(:max_example) }

  describe 'create' do
    it 'creates a comment and returns 201' do
      body = 'This is a cool comment'
      db_count = user.comments.count

      post '//mailman.reading.am/api/comments',
           'recipient' => MailPipe.encode_mail_recipient('reply', user, comment),
           'stripped-text' => body

      expect(response.status).to eq(201)
      expect(user.comments.count).to eq(db_count + 1)
      expect(user.comments.last.body).to eq(body)
    end
  end
end
