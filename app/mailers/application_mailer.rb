class ApplicationMailer < ActionMailer::Base
  helper :mail
  default from: "Reading <mailman@#{DOMAIN}>"
end
