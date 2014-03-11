class UserMailerMentionedJob
  include SuckerPunch::Job
  workers 4

  def perform comment, user
    ActiveRecord::Base.connection_pool.with_connection do
      UserMailer.mentioned(comment, user).deliver
    end
  end

end