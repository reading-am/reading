class UserMailer < ActionMailer::Base
  helper :posts, :mail
  default from: "Reading <mailman@reading.am>"

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
    mail(
      :to       => @subject.email,
      :subject  => "#{@enactor.display_name} mentioned you in a comment at \"#{@comment.page.display_title}\""
    )
  end

  def welcome(user)
    @user = user
    mail(
      :to       => @user.email,
      :from     => "Greg & Max <greg-and-max@reading.am>",
      :subject  => "Welcome to Reading!"
    )
  end

  def digest(user)
    @user   = user
    #@posts  = @user.unread_since(@user.mail_digest.days.ago).limit(50)
    @posts  = @user.unread_since(9999.days.ago).limit(100) # for testing
    mail(
      :to       => @user.email,
      :subject  => "Your Reading Digest - #{Time.now.strftime("%b %d, %Y")}"
    )
  end

end
