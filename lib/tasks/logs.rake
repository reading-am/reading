# -*- coding: utf-8 -*-
namespace :logs do

  desc 'Parse and post requests to mailgun routes'
  task :repost_emails, [:file] => [:environment] do |t, args|
    ApplicationRecord.observers.disable :all

    File.open(args.file, 'r') do |f|
      f.each_line do |line|
        begin
          # Find the params in the log entry
          reg_match = line.match(/Parameters: ({[^}]*})/)
          next unless reg_match

          # Parse the string representation of a hash using YAML
          params = YAML.load(reg_match[1].gsub(/=>/, ': '))
          next unless params['recipient']

          bits = MailPipe.decode_mail_recipient(params['recipient'])
          user = bits[:user]
          next unless bits[:user] == bits[:subject]

          text = params['stripped-text'] # this comes from mailgun
          # check to see if the body contains yep or nope
          if !text.match(/(^|\s)yep($|\s|:)/i).nil?
            yn = true
          elsif !text.match(/(^|\s)nope($|\s|:)/i).nil?
            yn = false
          else
            yn = nil
          end

          url = Twitter::Extractor::extract_urls(text)[0]
          next if url.blank?

          page = Page.find_or_create_by_url(url: url)
          # A post is a duplicate if it's the exact same page and within 1hr of the last post
          post = Post.recent_by_user_and_page(user, page, 7.days.ago).first || Post.new(user: user, page: page, yn: yn)

          if post.new_record?
            date = DateTime.parse(params['Date'])
            post.created_at = date
            post.updated_at = date
            post.save

            if page.created_at > date
              page.update created_at: date, updated_at: date
            end

            puts "Create: User:#{user.username} Post:#{post.id} Page:#{page.url}"
          end
        rescue
          next
        end
      end
    end
  end
end
