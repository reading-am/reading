SitemapGenerator::Sitemap.default_host  = "https://#{DOMAIN}"
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
    add "/#{user.username}",            :changefreq => 'hourly',  :lastmod => post.blank?       ? user.updated_at : post.updated_at, :priority => 0.7
    add "/#{user.username}/list",       :changefreq => 'hourly',  :lastmod => feed.blank?       ? user.updated_at : feed.updated_at
    add "/#{user.username}/following",  :changefreq => 'daily',   :lastmod => following.blank?  ? user.updated_at : following.updated_at
    add "/#{user.username}/followers",  :changefreq => 'daily',   :lastmod => follower.blank?   ? user.updated_at : follower.updated_at
  end
  Comment.find_each do |comment|
    add "/#{comment.user.username}/comments/#{comment.id}", :changefreq => 'weekly', :lastmod => comment.updated_at
  end
end
