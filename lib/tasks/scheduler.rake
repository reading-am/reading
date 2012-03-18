desc "Send out the daily Reading Digest"
task :send_daily_digest => :environment do
  puts "Sending emails..."
  # UserMailer.delay.digest user, :daily
  puts "done."
end

desc "Send out the weekly Reading Digest"
task :send_weekly_digest => :environment do
  puts "Sending emails..."
  # UserMailer.delay.digest user, :weekly
  puts "done."
end
