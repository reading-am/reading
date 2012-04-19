class Page < ActiveRecord::Base
  belongs_to :domain, :counter_cache => true
  has_one  :readability_data
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts
  has_many :comments, :dependent => :destroy

  validates_presence_of :url, :domain
  validates_uniqueness_of :url

  before_validation { parse_domain }
  after_create :populate_readability

  # search
  searchable do
    text :title, :url
    text :content do
      if readability_data
        Sanitize.clean readability_data.content rescue nil
      end
    end
  end
  handle_asynchronously :solr_index

  # NOTE - properties prefixed with r_ (r_title, r_excerpt)
  # are from readability_data

private

  def parse_domain
    self.domain = Domain.find_or_create_by_name(Addressable::URI.parse(self.url).host)
  end

public

  def wrapped_url
    "http://#{DOMAIN}/#{self.url}"
  end

  def display_title
    if !title.blank?
      title
    elsif !r_title.blank? and r_title != "(no title provided)"
      r_title
    else
      url
    end
  end

  def excerpt
    r_excerpt.gsub(/(&nbsp;|\s|&#13;|\r|\n)+/, " ") unless r_excerpt.blank?
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
    r = ReadabilityData.create :page => self
    self.r_title = r.title
    self.r_excerpt = r.excerpt
    self.save
  end

  def simple_obj to_s=false
    {
      :type   => 'Page',
      :id     => to_s ? id.to_s : id,
      :url    => url,
      :title  => title
    }
  end
end
