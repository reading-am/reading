class UserMailerNewFollowerJob
  include SuckerPunch::Job
  workers 4

  def perform subject, enactor
    ActiveRecord::Base.connection_pool.with_connection do
      UserMailer.new_follower(subject, enactor).deliver
    end
  end

end
