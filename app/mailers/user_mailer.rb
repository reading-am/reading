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

  def digest(user)
    @user   = user
    @posts  = @user.unread_since(@user.mail_digest.days.ago).limit(30)
    mail(
      :to       => @user.email,
      :subject  => "Your Reading Digest - #{Time.now.strftime("%b %d, %Y")}"
    )
  end

end
