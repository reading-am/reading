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

end
