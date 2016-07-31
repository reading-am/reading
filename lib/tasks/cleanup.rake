# -*- coding: utf-8 -*-
namespace :cleanup do

  desc "Convert unserialized Ruby objects to JSON"
  task :fix_unserialized => :environment do
    ApplicationRecord.observers.disable :all

    User.where('urls LIKE ?', '--- %').find_each do |user|
      puts "### User #{user.id} | #{user.username}", "Before:", user.urls, "\n"
      user.update_column :urls, Hash[user.urls.split("\n")[1..-1].map { |p| p.split(': ', 2) }].to_json
      puts "After:", user.urls, "\n\n"
    end
  end

  desc "Migrate URLs that point to NYT interstitial pages"
  task :nyt_urls => :environment do

    def swap_url page, url, domain
      uri = Addressable::URI.parse(url)
      uri.host = domain.name

      puts "swap_url: #{page.id}\n#{page.url}\n#{uri}\n\n"

      page.url = "#{uri}"
      page.domain = domain
      page.save

      page.readability_data.destroy
      page.populate_remote_page_data
      page.populate_remote_meta_data
      page.save
    end

    new_domain = Domain.find_by_name("www.nytimes.com")

    Page.where('url like ?', 'https://myaccount.nytimes.com/auth/login?URI=%').each do |p|
      url = Page.cleanup_url(Addressable::URI.parse(p.url).query_values["URI"])
      swap_url p, url, new_domain
    end

    Domain.find_by_name("www-nc.nytimes.com").pages.each do |p|
      swap_url p, p.url, new_domain
    end
  end

  desc "Populate the medium type for pages missing it"
  task :populate_medium => :environment do
    ApplicationRecord.observers.disable :all

    pages = Page.where(:medium => nil)
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      puts_header page, total, progress
      page.medium = page.parse_medium
      puts "#{page.medium} : #{page.url}"
      page.save
    end
  end

  desc "Populate remote oembed data for pages missing it"
  task :populate_remote_oembed => :environment do
    ApplicationRecord.observers.disable :all

    pages = Page.where(:oembed => nil).where("head_tags like ?", "%oembed%")
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      puts_header page, total, progress
      puts page.oembed_tags['json'] || page.oembed_tags['xml']
      page.oembed = page.remote_oembed
      page.save
    end
  end

  desc "Populate remote page data for pages missing it, resolve the canonical url, and combine with duplicate urls"
  task :populate_remote_page_data => :environment do
    ApplicationRecord.observers.disable :all
    Page.crawl_timeout = timeout

    pages = Page.where(:head_tags => nil)
    if domain
      pages = pages.where(:domain_id => Domain.find_by_name(domain).id)
    end
    if start_id
      pages = pages.where("id >= ?", start_id)
    end

    total = pages.count
    progress = 0
    pages.find_each do |page|
      progress += 1
      puts_header page, total, progress

      begin
        page.populate_remote_page_data
      rescue Exception => e
        puts "## #{e.message}"
        next
      end

      if page.url_changed?
        similarity = Text::WhiteSimilarity.similarity(strip_url(page.url.split('?')[0]), strip_url(page.url_was.split('?')[0]))
        puts "## URL will change"
        puts "from: #{page.url_was}"
        puts "to:   #{page.url}"
        puts "similarity: #{similarity}"

        if !update_urls?
          puts "Skipping."
          next
        end

        if similarity < min_similar
          if prompt_unsimilar
            puts "Update? (Y/n)"
            input = STDIN.gets.strip.downcase
          else
            input = "no"
          end
          if input[0] == "n"
            puts "Skipping."
            next # if the user said "no" then continue without changing anything
          end
        end
        dupe_page = Page.find_by_url page.url
        if dupe_page
          if dupe_page.id < page.id
            puts "## #{page.id} getting replaced by #{dupe_page.id}\n"
            puts "## url was: #{page.url_was}\nurl is: #{page.url}\nreplacement page url is: #{dupe_page.url}\n\n"
            page_to_replace = page
            page_to_keep = dupe_page
          else
            puts "## #{page.id} replacing #{dupe_page.id}\n"
            puts "## url was: #{page.url_was}\nurl is: #{page.url}\n\n"
            page.domain = Domain.where(name: Addressable::URI.parse(page.url).host).first_or_create
            page_to_replace = dupe_page
            page_to_keep = page
          end
          page_to_replace.posts.each do |post|
            post.page = page_to_keep
            post.save
          end
          page_to_replace.comments.each do |comment|
            comment.page = page_to_keep
            comment.save
          end
          page_to_replace.destroy
        end
      end
      if !page.destroyed?
        page.save
        puts "## #{page.id} populated and saved"
      else
        puts "## #{page.id} destroyed"
      end
    end
  end

  desc "Populate DescribeData for pages missing it"
  task :populate_describe_data, [:modify, :hours] => [:environment] do |t, args|
    args.with_defaults modify: false, hours: 48
    ApplicationRecord.observers.disable :all
    
    modify = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(args.modify)
    hours = args.hours.to_i

    pages = Page.where(has_describe_data: 0)
    pages = pages.where("created_at >= ?", hours.hours.ago)
    total = pages.count
    progress = 0
    populated = 0

    if total == 0
      puts "None found. Describe must be working swimmingly."
    elsif !modify
      puts "*** Preview Only ***"
    end

    pages.find_each do |page|
      progress += 1
      puts_header page, total, progress
      puts "#{page.url}\n"
      if modify
        page.populate_describe_data
        if page.describe_data.blank?
          puts "× There was an error.\n"
        else
          page.save if page.changed?
          page.describe_data.save if page.describe_data.changed?
          puts "✔ Successfully populated.\n"
          populated += 1
        end
      end
    end

    puts "\n↪ #{populated} of #{total} populated\n" if modify
  end

  def puts_header model, total, progress
      puts "\n------- #{model.class.name} #{model.id}: #{"%0#{total.to_s.length}d" % progress} of #{total} -------\n"
  end

  def timeout
    ENV['timeout'].blank? ? false : ENV['timeout'].to_i
  end

  def domain
    ENV['domain'] || false
  end

  def start_id
    ENV['start_id'] || false
  end

  def strip_url url
    url.gsub(/https?/,'').gsub('www.','').gsub('/','').gsub(/#!?/,'').gsub('?','').gsub('.','').gsub(':','')
  end

  def prompt_unsimilar
    ENV['prompt_unsimilar'].blank? || ENV['prompt_unsimilar'].downcase != 'false'
  end

  def min_similar
    @min_similar ||= Float(ENV['min_similar']) rescue 1.0
  end

  def update_urls?
    ENV['update_urls'].blank? || ENV['update_urls'].downcase != 'false'
  end

end
