# encoding: utf-8

# per: http://www.billrowell.com/2012/02/01/create-an-xml-sitemap-on-heroku-via-amazon-s3/
class SitemapController < ApplicationController
  def index
    params[:partial] = '_index' if params[:partial].nil?
    redirect_to "#{S3_BUCKET}/sitemaps/sitemap#{params[:partial]}.xml.gz"
  end
end
