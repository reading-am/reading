class UserMailerWelcomeJob
  include SuckerPunch::Job
  workers 4

  def perform user
    ActiveRecord::Base.connection_pool.with_connection do
      UserMailer.welcome(user).deliver
    end
  end

end
