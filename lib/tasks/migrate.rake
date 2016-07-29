namespace :migrate do

  desc "Migrate the media_type for Describe integration"
  task :describe_media_type => :environment do
    ApplicationRecord.observers.disable :all

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
    ApplicationRecord.observers.disable :all

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
    ApplicationRecord.observers.disable :all

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
    ApplicationRecord.observers.disable :all

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

  desc "Migrate all attributes for Describe integration"
  task :describe_full, [:start_id] => [:environment] do |t, args|
    args.with_defaults start_id: 1
    ApplicationRecord.observers.disable :all

    pages = Page.where("id >= ?", args.start_id)
    total = pages.count
    progress = 0

    pages.find_each do |page|
      progress += 1
      page.media_type = page.media_type_migration
      page.description = page.description_migration
      page.embed = page.embed_migration
      page.title = page.title_migration
      if page.changed?
        puts_header page, total, progress
        puts page.url
        page.save
      end
    end
  end

  desc "Delete associations with foreign keys that point to deleted records"
  task :keys_missing_recs => :environment do
    ApplicationRecord.observers.disable :all

    puts "Fixing comments that should have a nil post_id"
    c = Comment.includes(:post).where("comments.post_id IS NOT NULL AND posts.id IS NULL")
    c.each {|comment| comment.update_attribute :post_id, nil}

    puts "Fixing posts the a replies to posts that no longer exist"
    p = Post.joins("LEFT JOIN posts AS refposts ON refposts.id = posts.referrer_post_id").where("posts.referrer_post_id IS NOT NULL AND refposts.id IS NULL").readonly(false)
    p.each {|post| post.update_attribute :referrer_post_id, nil}

    puts "Fixing Readability data for pages that no longer exist"
    r = ReadabilityData.includes(:page).where("readability_data.page_id IS NOT NULL AND pages.id IS NULL")
    r.each {|rd| rd.destroy}
  end

  def puts_header model, total, progress
      puts "\n------- #{model.class.name} #{model.id}: #{"%0#{total.to_s.length}d" % progress} of #{total} -------\n"
  end

end
