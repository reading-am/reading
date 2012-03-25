# per: http://www.billrowell.com/2012/02/01/create-an-xml-sitemap-on-heroku-via-amazon-s3/
class SitemapController < ApplicationController
   def index
      redirect_to "http://reading-#{Rails.env}.s3.amazonaws.com/sitemaps/sitemap_index.xml.gz"
   end
end
