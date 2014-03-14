desc "This task is called by the Heroku scheduler add-on"

task :send_digest => :environment do
  puts "Sending emails..."
  freq = [1] # daily digesters
  freq << 2 if Time.now.wday % 2 > 0 # every other day
  freq << 7 if Time.now.wday == 1 # if it's Monday, send to the weekly people
  User.digesting_on_day(freq).each do |user|
    UserMailer.delay.digest(user)
  end
  puts "done."
end
