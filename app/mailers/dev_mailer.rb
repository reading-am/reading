class DevMailer < ApplicationMailer
  default from: "dev@#{DOMAIN}", to: "dev@#{DOMAIN}"

  def dump(var)
    @var = var
    mail(
      :subject => "Var Dump"
    )
  end

end
