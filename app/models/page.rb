class Page < ActiveRecord::Base
  belongs_to :domain
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts

  validates_presence_of :url, :domain

  before_validation { parse_domain }
  before_create :populate_readability

  # search
  searchable do
    text :title, :url
    text :content do
      if meta and meta['content']
        Sanitize.clean meta['content']
      end
    end
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
    if meta and meta['title']
      meta['title']
    elsif !title.blank?
      title
    else
      url
    end
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

  def populate_readability
    c = Curl::Easy.new
    c.follow_location = true
    c.url = "https://www.readability.com/api/content/v1/parser?token=#{READABILITY_TOKEN}&url=#{self.url}"
    c.perform
    self.readability = c.body_str
  end

  def meta
    ActiveSupport::JSON.decode(readability) unless readability.blank?
  end
end
