class AdminMailer < ApplicationMailer

  def new_blockage(subject, enactor)
    @enactor = enactor
    @subject = subject
    mail(
      :to       => "greg@#{ROOT_DOMAIN}",
      :subject  => "Blocked: #{@enactor.username} blocked #{@subject.username}"
    )
  end

  def blockage_removed(subject, enactor)
    @enactor = enactor
    @subject = subject
    mail(
      :to       => "greg@#{ROOT_DOMAIN}",
      :subject  => "Unblocked: #{@enactor.username} unblocked #{@subject.username}"
    )
  end

end
