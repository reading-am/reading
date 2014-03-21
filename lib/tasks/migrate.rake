namespace :migrate do

  desc "Migrate the media_type for Describe integration"
  task :describe_media_type => :environment do
    ActiveRecord::Base.observers.disable :all

    pages = Page.where("head_tags IS NOT NULL")
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      puts_header page, total, progress
      page.media_type = page.media_type_migration
      puts "#{page.media_type} : #{page.url}"
      page.save
    end
  end

  def puts_header model, total, progress
      puts "\n------- #{model.class.name} #{model.id}: #{"%0#{total.to_s.length}d" % progress} of #{total} -------\n"
  end

end
