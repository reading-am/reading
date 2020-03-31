# encoding: utf-8
module Mailman
  class CommentsController < Api::V1::ApiController

    def create
      bits = MailPipe::decode_mail_recipient(params[:recipient]) || {}
      comment = Comment.new body: params['stripped-text'], # this comes from mailgun
                            user: bits[:user],
                            parent: bits[:subject],
                            page: bits[:subject].page

      head comment.save ? :created : :bad_request
    end
  end
end
