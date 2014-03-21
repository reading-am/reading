namespace :migrate do

  desc "Migrate the media_type for Describe integration"
  task :describe_media_type => :environment do
    ActiveRecord::Base.observers.disable :all

    pages = Page.where("head_tags IS NOT NULL")
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      page.media_type = page.media_type_migration
      if page.changed?
        puts_header page, total, progress
        puts "#{page.media_type} : #{page.url}"
        page.save
      end
    end
  end

  desc "Migrate the description for Describe integration"
  task :describe_description => :environment do
    ActiveRecord::Base.observers.disable :all

    # we have two data sources
    pages = Page.where("r_excerpt IS NOT NULL OR head_tags IS NOT NULL")
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      page.description = page.description_migration
      if page.changed?
        puts_header page, total, progress
        puts "#{page.url}\n#{page.description}"
        page.save
      end
    end
  end

  desc "Migrate the embed for Describe integration"
  task :describe_embed => :environment do
    ActiveRecord::Base.observers.disable :all

    # we have two data sources
    pages = Page.where("embed IS NULL AND (oembed IS NOT NULL OR head_tags IS NOT NULL)")
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      page.embed = page.embed_migration
      if page.changed?
        puts_header page, total, progress
        puts "#{page.url}\n#{page.embed}"
        page.save
      end
    end
  end

  desc "Migrate the title for Describe integration"
  task :describe_title => :environment do
    ActiveRecord::Base.observers.disable :all

    pages = Page.all
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      page.title = page.title_migration
      if page.changed?
        puts_header page, total, progress
        puts "#{page.url}\n#{page.title}"
        page.save
      end
    end
  end

  def puts_header model, total, progress
      puts "\n------- #{model.class.name} #{model.id}: #{"%0#{total.to_s.length}d" % progress} of #{total} -------\n"
  end

end
