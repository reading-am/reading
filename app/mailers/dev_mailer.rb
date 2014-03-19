class DevMailer < ApplicationMailer
  default from: "dev@#{ROOT_DOMAIN}", to: "dev@#{ROOT_DOMAIN}"

  def dump(var)
    @var = var
    mail(
      :subject => "Var Dump"
    )
  end

end
