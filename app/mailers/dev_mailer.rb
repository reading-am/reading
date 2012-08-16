class DevMailer < ActionMailer::Base
  default from: "dev@reading.am", to: "dev@reading.am"

  def dump(var)
    @var = var
    mail(
      :subject => "Var Dump"
    )
  end

end
