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

  def digest(user)
    @user   = user
    @posts  = @user.unread_since(@user.mail_digest.days.ago).limit(30)
    #@posts  = @user.unread_since(15.days.ago).limit(10) # for testing
    mail(
      :to       => @user.email,
      :subject  => "Your Reading Digest - #{Time.now.strftime("%b %d, %Y")}"
    )
  end

end
