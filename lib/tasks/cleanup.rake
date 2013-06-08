namespace :cleanup do

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

  desc "Populate remote page data for pages missing it, resolve the canonical url, and combine with duplicate urls"
  task :populate_remote_page_data => :environment do
    Page.observers.disable :all

    pages = Page.where(:head_tags => nil)
    if !ENV['domain'].blank?
      pages = pages.where(:domain_id => Domain.find_by_name(ENV['domain']).id)
    end

    total = pages.count
    progress = 0
    pages.find_each do |page|
      progress += 1
      puts "\n------- Page #{page.id}: #{"%0#{total.to_s.length}d" % progress} of #{total} -------\n"

      begin
        page.populate_remote_page_data
      rescue Curl::Err::ConnectionFailedError
        puts "## Curl Timeout\n#{page.id} : #{page.url}"
        next
      rescue Curl::Err::HostResolutionError
        puts "## Curl Not Found\n#{page.id} : #{page.url}"
        next
      rescue Exception => e
        puts "## #{e.message}"
        next
      end

      if page.url_changed?
        minor = strip_url(page.url) == strip_url(page.url_was)
        next unless update_urls? || minor
        puts "## URL will change"
        puts "from: #{page.url_was}"
        puts "to:   #{page.url}"
        if !force? && !minor
          puts "Continue? (y/n)"
          input = STDIN.gets.strip.downcase
          if input[0] == "n"
            puts "## Page #{page.id} will remain unchanged."
            next # if the user said "no" then continue without changing anything
          end
        elsif minor
          puts "Minor URL change. Updating."
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
            page.domain = Domain.find_or_create_by_name(Addressable::URI.parse(page.url).host)
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

  def strip_url url
    url.gsub(/https?/,'').gsub('www.','').gsub('/','').gsub(/#!?/,'').gsub('?','')
  end

  def force?
    !ENV['force'].blank? && ENV['force'].downcase == 'true'
  end

  def update_urls?
    ENV['update_urls'].blank? || ENV['update_urls'].downcase != 'false'
  end

end
