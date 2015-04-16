# encoding: utf-8
module Mailman
  class PostsController < Api::V1::ApiController

    def create
      text = params['stripped-text'] # this comes from mailgun

      # check to see if the body contains yep or nope
      if !text.match(/(^|\s)yep($|\s|:)/i).nil?
        yn = true
      elsif !text.match(/(^|\s)nope($|\s|:)/i).nil?
        yn = false
      end

      if bits = MailPipe::decode_mail_recipient(params[:recipient])
        # make sure the user is posting to their own account
        user = bits[:user] if bits[:user] == bits[:subject]
      end

      page = Page.find_or_create_by_url(url: Twitter::Extractor::extract_urls(text)[0])
      # A post is a duplicate if it's the exact same page and within 1hr of the last post
      post = Post.recent_by_user_and_page(user, page).first || Post.new(user: user, page: page, yn: yn)

      if (post.new_record? and post.save) or (!post.new_record? and post.touch)
        head :created
      else
        head post.user.blank? ? :forbidden : :bad_request
      end
    end
    add_transaction_tracer :create
  end
end
