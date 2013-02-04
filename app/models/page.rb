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
    # this is a sniff test for links submitted raw, as just a url
    page.populate_remote_data if page.title.nil?
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

  META_TAG_NAMESPACES = ['og','twitter']

  # NOTE - properties prefixed with r_ (r_title, r_excerpt)
  # are from readability_data

private

  def parse_domain
    self.domain = Domain.find_or_create_by_name(parsed_url.host)
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
    if (!meta_tags["og"]["title"].blank? rescue false)
      meta_tags["og"]["title"]
    elsif (!meta_tags["twitter"]["title"].blank? rescue false)
      meta_tags["twitter"]["title"]
    elsif !title.blank?
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

  def curl
    if @curl.blank?
      @curl = Curl::Easy.new url
      @curl.follow_location = true
      @curl.perform
    end
    @curl
  end

  def html
    @html ||= Nokogiri::HTML(curl.body_str)
  end

  def resolved_url
    curl.last_effective_url
  end

  def defacto_url
    !@curl.blank? && !@curl.body_str.nil? ? resolved_url : url
  end

  def parsed_url
    @parsed_url ||= Addressable::URI.parse defacto_url
  end

  def remote_title
    doc_title = html.search('title').first
    doc_title.nil? ? '' : doc_title.text
  end

  def remote_canonical
    domain = parsed_url.host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"
    protocol = "#{parsed_url.scheme}:"

    search = html.search('link[rel=canonical]')
    if search.length
      canonical = search.attr('href').to_s
    elsif remote_meta_tags && !remote_meta_tags["og"].blank? && !remote_meta_tags["og"]["url"].blank?
      canonical = remote_meta_tags["og"]["url"] 
    elsif remote_meta_tags && !remote_meta_tags["twitter"].blank? && !remote_meta_tags["twitter"]["url"].blank?
      canonical = remote_meta_tags["twitter"]["url"] 
    else
      canonical = false
    end

    if canonical.blank?
      canonical = false
    # protocol relative url
    elsif canonical[0..1] == "//"
      canonical = "#{protocol}#{canonical}"
    # relative url
    elsif canonical[0] == "/"
      canonical = "#{protocol}//#{parsed_url.host}#{canonical}"
    # sniff test for mangled urls
    elsif !canonical.include?("//") or
    # sniff test for urls on a different root domain
    !canonical.include?(domain)
      canonical = false
    end

    canonical
  end

  def remote_meta_tags
    # this has a JS companion in bookmarklet/real_loader.rb#get_meta_tags()
    meta_tags = nil
    regex = Regexp.new("^(#{META_TAG_NAMESPACES.join('|')}):(.+)$", true)
    html.css('meta').each do |m|
      if m.attribute('property') && m.attribute('property').to_s.match(regex)
        meta_tags = {} if meta_tags.blank?
        meta_tags[$1] = {} if meta_tags[$1].blank?
        meta_tags[$1][$2] = m.attribute('content').to_s
      end
    end
    meta_tags
  end

  def populate_remote_data
    self.url = remote_canonical unless remote_canonical.blank?
    self.title = remote_title
    self.meta_tags = remote_meta_tags
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
