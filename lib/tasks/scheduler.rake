desc "Send out the Reading Digest"
task :send_digest => :environment do
  puts "Sending emails..."
  freq = [1] # daily digesters
  freq << 7 if Time.now.wday == 1 # if it's Monday, send to the weekly people
  User.digesting_on_day(freq).each do |user|
    UserMailer.delay.digest(user)
  end
  puts "done."
end
