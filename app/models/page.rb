class Page < ActiveRecord::Base
  belongs_to :domain
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts

  validates_presence_of :url, :domain

  before_validation { parse_domain }

  # search
  searchable do
    text :title, :url
  end
  handle_asynchronously :solr_index

private

  def parse_domain
    self.domain = Domain.find_or_create_by_name(Addressable::URI.parse(self.url).host)
  end

public

  def wrapped_url
    "http://#{DOMAIN}/#{self.url}"
  end

  def display_title
    !title.blank? ? title : url
  end

  def remote_title
    c = Curl::Easy.new
    c.follow_location = true
    c.url = self.url
    c.perform
    doc = Nokogiri::HTML(c.body_str)
    title = doc.search('title').first
    title.nil? ? '' : title.text
  end
end
