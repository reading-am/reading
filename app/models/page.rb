class Page < ActiveRecord::Base
  belongs_to :domain, :counter_cache => true
  has_one  :readability_data, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts
  has_many :comments, :dependent => :destroy

  serialize :meta_tags

  validates_presence_of :url, :domain
  validates_uniqueness_of :url

  before_validation { parse_domain }
  after_create :populate_readability

  before_create do |page|
    page.title = page.remote_title if page.title.nil?
  end

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

  def self.normalize_url(url)
    # if it doesn't start with a protocol
    # it's most likely just a TLD, manually entered
    if url[0..3] != 'http'
      c = Curl::Easy.new
      c.follow_location = true
      c.url = url
      c.perform
      url = c.last_effective_url
    end

    url = Addressable::URI.parse(url)

    # Get rid of trailing hash
    url.fragment = nil if url.fragment.blank?

    # Consider removing trailing slashes
    # http://googlewebmastercentral.blogspot.com/2010/04/to-slash-or-not-to-slash.html
    # http://stackoverflow.com/questions/5948659/trailing-slash-in-urls-which-style-is-preferred/5949201

    url.to_s
  end

  def self.find_by_url(url)
    where(:url => self.normalize_url(url)).limit(1).first
  end

  def self.find_or_create_by_url(attributes)
    attributes[:url] = self.normalize_url(attributes[:url])

    self.find_by_url(attributes[:url]) || self.create(attributes)
  end

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

  def channels
    [
      "pages"
    ]
  end

  def simple_obj to_s=false
    {
      :type   => 'Page',
      :id     => to_s ? id.to_s : id,
      :url    => url,
      :title  => display_title,
      :excerpt => excerpt,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end
end
