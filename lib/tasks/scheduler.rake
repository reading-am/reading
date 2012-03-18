desc "Send out the daily Reading Digest"
task :send_daily_digest => :environment do
  puts "Sending emails..."
  freq = 1
  User.digesting_on_day(freq).each do |user|
    UserMailer.delay.digest(user, freq)
  end
  puts "done."
end

desc "Send out the weekly Reading Digest"
task :send_weekly_digest => :environment do
  puts "Sending emails..."
  freq = 7
  User.digesting_on_day(freq).each do |user|
    UserMailer.delay.digest(user, freq)
  end
  puts "done."
end
