class UserMailerDigestJob
  include SuckerPunch::Job
  workers 4

  def perform user, num_days=nil, limit=25
    ActiveRecord::Base.connection_pool.with_connection do
      UserMailer.digest(user, num_days, limit).deliver
    end
  end

end
