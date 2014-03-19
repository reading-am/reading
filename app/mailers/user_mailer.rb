class UserMailer < ApplicationMailer
  helper :posts

  def new_follower(subject, enactor)
    @enactor = enactor
    @subject = subject
    mail(
      :to       => @subject.email,
      :subject  => "#{@enactor.display_name} is now following you on Reading.am"
    )
  end

  def mentioned(comment, subject)
    @enactor = comment.user
    @subject = subject
    @comment = comment
    @url = @comment.post.blank? ? @comment.page.wrapped_url : @comment.post.wrapped_url

    mail(
      :to       => @subject.email,
      :reply_to => MailPipe::encode_mail_recipient('reply', @subject, @comment),
      :subject  => "#{@enactor.display_name} mentioned you in a comment at \"#{@comment.page.display_title}\""
    )
  end

  def shown_a_page(comment, subject)
    @enactor = comment.user
    @subject = subject
    @comment = comment
    @url = @comment.post.blank? ? @comment.page.wrapped_url : @comment.post.wrapped_url

    mail(
      :to       => @subject.email,
      :reply_to => MailPipe::encode_mail_recipient('reply', @subject, @comment),
      :subject  => "#{@enactor.display_name} wants to show you \"#{@comment.page.display_title}\""
    )
  end

  def comments_welcome(user, comment)
    @user = user
    @comment = comment

    mail(
      :to       => @user.email,
      :from     => "Greg <greg@#{ROOT_DOMAIN}>",
      :subject  => "Help Us Test Comments, #{@user.first_name}!"
    )
  end

  def welcome(user)
    @user = user
    mail(
      :to       => @user.email,
      :from     => "Greg <greg@#{ROOT_DOMAIN}>",
      :subject  => "Welcome to Reading, #{@user.first_name}!"
    )
  end

  def destroyed(user)
    @user = user
    mail(
      :to       => @user.email,
      :from     => "Greg <greg@#{ROOT_DOMAIN}>",
      :subject  => "Here lies @#{@user.username}, may he / she / it rest in peace."
    )
  end

  def digest(user, num_days=nil, limit=25)
    @user   = user
    num_days ||= @user.mail_digest
    @posts  = @user.unread_since(num_days.days.ago).limit(limit)
    mail(
      :to       => @user.email,
      :subject  => "Your Reading Digest - #{Time.now.strftime("%b %d, %Y")}"
    )
  end

end
