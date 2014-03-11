class UserMailerShownAPageJob
  include SuckerPunch::Job
  workers 4

  def perform comment, user
    ActiveRecord::Base.connection_pool.with_connection do
      UserMailer.shown_a_page(comment, user).deliver
    end
  end

end
