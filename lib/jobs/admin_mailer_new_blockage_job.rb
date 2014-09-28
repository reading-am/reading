class AdminMailerNewBlockageJob
  include SuckerPunch::Job
  workers 4

  def perform subject, enactor
    ActiveRecord::Base.connection_pool.with_connection do
      AdminMailer.new_blockage(subject, enactor).deliver
    end
  end

end
