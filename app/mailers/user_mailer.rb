class UserMailer < ActionMailer::Base
  default from: "Reading <mailman@reading.am>"

  def new_follower(subject, enactor)
    @enactor = enactor
    @subject = subject
    mail(
      :to       => @subject.email,
      :subject  => "#{@enactor.display_name} is now following you on Reading.am"
    )
  end

  def digest(user, timeframe)
    @user     = user
    datetime  = (timeframe == :daily ? 1.day.ago : 7.days.ago) # it'll either be daily or weekly
    @posts    = @user.unread_since datetime
    mail(
      :to       => @user.email,
      :subject  => "Your Reading Digest - #{Time.now.strftime("%b %d, %Y")}"
    )
  end
end
