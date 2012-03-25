SitemapGenerator::Sitemap.default_host  = "https://#{DOMAIN}"
SitemapGenerator::Sitemap.sitemaps_host = "http://reading-#{Rails.env}.s3.amazonaws.com/"
SitemapGenerator::Sitemap.public_path   = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new

SitemapGenerator::Sitemap.create do
  add '/everybody', :priority => 0.7, :changefreq => 'always'
  User.find_each do |user|
    post = user.posts.first
    feed = user.feed.first
    following = user.relationships.last
    follower = user.reverse_relationships.last
    add "/#{user.username}",            :changefreq => 'hourly',  :lastmod => post.blank?       ? user.created_at : post.created_at, :priority => 0.7
    add "/#{user.username}/list",       :changefreq => 'hourly',  :lastmod => feed.blank?       ? user.created_at : feed.created_at
    add "/#{user.username}/following",  :changefreq => 'daily',   :lastmod => following.blank?  ? user.created_at : following.created_at
    add "/#{user.username}/followers",  :changefreq => 'daily',   :lastmod => follower.blank?   ? user.created_at : follower.created_at
  end
end
