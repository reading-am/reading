SitemapGenerator::Sitemap.default_host  = ROOT_URL
SitemapGenerator::Sitemap.public_path   = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new({
  aws_access_key_id:      ENV['S3_KEY'],
  aws_secret_access_key:  ENV['S3_SECRET'],
  fog_directory:          ENV['S3_BUCKET'],
  fog_provider:           'AWS'
})

SitemapGenerator::Sitemap.create do
  add '/everybody', priority: 0.7, changefreq: 'always'
  User.find_each do |user|
    post      = user.posts.first
    feed      = user.feed.first
    following = user.relationships.last
    follower  = user.reverse_relationships.last
    pagemap   = {
      dataobjects: [
        type: 'user',
        id: user.id,
        attributes: [
          {name: 'username',  value: user.username},
          {name: 'name',      value: user.name},
          {name: 'link',      value: user.link}
        ]
      ]
    }

    add "/#{user.username}",            changefreq: 'hourly',  lastmod: post.blank?       ? user.updated_at : post.updated_at, priority: 0.7, pagemap: pagemap
    add "/#{user.username}/list",       changefreq: 'hourly',  lastmod: feed.blank?       ? user.updated_at : feed.updated_at
    add "/#{user.username}/following",  changefreq: 'daily',   lastmod: following.blank?  ? user.updated_at : following.updated_at
    add "/#{user.username}/followers",  changefreq: 'daily',   lastmod: follower.blank?   ? user.updated_at : follower.updated_at
  end
  Comment.includes(:user, :page).find_each do |comment|
    pagemap = {
      dataobjects: [
        type: 'comment',
        id: comment.id,
        attributes: [
          {name: 'by',    value: comment.user.username},
          {name: 'on',    value: comment.page.url},
          {name: 'body',  value: comment.body}
        ]
      ]
    }

    add "/#{comment.user.username}/comments/#{comment.id}", changefreq: 'weekly', lastmod: comment.updated_at, pagemap: pagemap
  end
end
