class ApplicationMailer < ActionMailer::Base
  helper :mail
  default from: "Reading <mailman@#{DOMAIN}>"

  def encode_mail_recipient user, subject
    type = "c"
    hash = Digest::SHA1.hexdigest("#{type}#{subject.id}#{user.token}")
    "#{type}-#{subject.id}-#{hash}-#{user.id}"
  end

end
