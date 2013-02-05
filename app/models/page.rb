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
  before_create :populate_remote_data
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

  META_TAG_NAMESPACES = ['og','twitter']

  # NOTE - properties prefixed with r_ (r_title, r_excerpt)
  # are from readability_data

private

  def parse_domain
    self.domain = Domain.find_or_create_by_name(Addressable::URI.parse(url).host)
  end

public

  def self.cleanup_url(url)
    parsed_url = Addressable::URI.parse(url)

    # Get rid of trailing hash
    parsed_url.fragment = nil if parsed_url.fragment.blank?

    # Consider removing trailing slashes
    # http://googlewebmastercentral.blogspot.com/2010/04/to-slash-or-not-to-slash.html
    # http://stackoverflow.com/questions/5948659/trailing-slash-in-urls-which-style-is-preferred/5949201

    parsed_url.to_s
  end

  def self.find_by_url(url, return_new=false)
    url = self.cleanup_url url
    if page = where(:url => url).limit(1).first
      page
    else
      page = self.new :url => url
      page.url = page.normalized_url
      found = where(:url => page.url).limit(1).first
      # if the page isn't found, we return a new instance so
      # we don't have to make another round trip for remote data
      # when we find_or_create
      found || !return_new ? found : page
    end
  end

  def self.find_or_create_by_url(attributes)
    page = self.find_by_url(attributes[:url], true)
    page.save if page.new_record?
    page
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
    @html ||= Nokogiri::HTML curl.body_str
  end

  def normalized_url
    remote_canonical ? remote_canonical : self.class.cleanup_url(resolved_url)
  end

  def resolved_url
    curl.last_effective_url
  end

  def remote_title
    doc_title = html.search('title').first
    doc_title.nil? ? '' : doc_title.text
  end

  def remote_canonical
    parsed_url = Addressable::URI.parse resolved_url
    domain = parsed_url.host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"
    protocol = "#{parsed_url.scheme}:"

    search = html.search('link[rel=canonical]')
    if search.length > 0
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
    self.url = normalized_url
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
      :meta_tags => meta_tags,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end
end
