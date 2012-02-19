class Page < ActiveRecord::Base
  belongs_to :domain
  has_one  :readability_data
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts

  validates_presence_of :url, :domain

  before_validation { parse_domain }
  after_create :populate_readability

  #default_scope :include => {:readability_data => :excerpt}}

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
    ReadabilityData.create :page => self
  end

  def meta
    if !readability.blank?
      Yajl::Parser.parse(readability) rescue nil
    end
  end
end
