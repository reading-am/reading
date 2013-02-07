class Page < ActiveRecord::Base
  belongs_to :domain, :counter_cache => true
  has_one  :readability_data, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :users, :through => :posts
  has_many :comments, :dependent => :destroy

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

  # initialize the parsed tag cache
  after_initialize do |page|
    page.head_tags = page.head_tags
  end

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
      page.url = page.remote_normalized_url
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

  def display_title
    if !meta_tags["og"]["title"].blank?
      meta_tags["og"]["title"]
    elsif !meta_tags["twitter"]["title"].blank?
      meta_tags["twitter"]["title"]
    elsif !title.blank?
      title
    elsif !r_title.blank? and r_title != "(no title provided)"
      r_title
    else
      url
    end
  end

  def wrapped_url
    "http://#{DOMAIN}/#{self.url}"
  end

  def excerpt
    r_excerpt.gsub(/(&nbsp;|\s|&#13;|\r|\n)+/, " ") unless r_excerpt.blank?
  end

  def head_tags=(str_or_nodes)
    # clear the parsed tags
    @tag_cache = {}
    self[:head_tags] = str_or_nodes.to_s
  end

  def head_tags
    @tag_cache ||= {}
    @tag_cache[:head_tags] ||= Nokogiri::HTML self[:head_tags]
  end

  def title_tag
    @tag_cache[:title_tag] ||= (head_tags.search('title').first.text rescue '')
  end

  def meta_tags
    # this has a JS companion in bookmarklet/real_loader.rb#get_meta_tags()
    if @tag_cache[:meta_tags].blank?
      @tag_cache[:meta_tags] = {'og'=>{},'twitter'=>{}}
      regex = Regexp.new("^(#{META_TAG_NAMESPACES.join('|')}):(.+)$", true)
      head_tags.search('meta').each do |m|
        if m.attribute('property') || m.attribute('name') || m.attribute('itemprop')
          key = (m.attribute('property') ? m.attribute('property') : m.attribute('name') ? m.attribute('name') : m.attribute('itemprop')).to_s
          val = (m.attribute('content') ? m.attribute('content') : m.attribute('value')).to_s
          if key.match(regex)
            @tag_cache[:meta_tags][$1][$2] = val 
          else
            @tag_cache[:meta_tags][key] = val
          end
        end
      end
    end
    @tag_cache[:meta_tags]
  end

  def link_tags
    if @tag_cache[:link_tags].blank?
      @tag_cache[:link_tags] = {}
      head_tags.search('link').each do |m|
        name = m.attribute('rel') ? m.attribute('rel').to_s : m.attribute('itemprop').to_s
        if name != ''
          @tag_cache[:link_tags][name] = m.attribute('href').to_s
        end
      end
    end
    @tag_cache[:link_tags]
  end

  def curl=(obj)
    # this setter is used during testing
    @curl = obj
  end

  def curl
    if @curl.blank?
      @curl = Curl::Easy.new url
      @curl.follow_location = true
      @curl.perform
    end
    @curl
  end

  def remote_html
    @remote_html ||= Nokogiri::HTML curl.body_str
  end

  def remote_resolved_url
    curl.last_effective_url
  end

  def remote_normalized_url
    remote_canonical_url ? remote_canonical_url : self.class.cleanup_url(remote_resolved_url)
  end

  def remote_head_tags
    remote_html.search('title,meta,link:not([rel=stylesheet])')
  end

  def remote_canonical_url
    parsed_url = Addressable::URI.parse(remote_resolved_url)
    domain = parsed_url.host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"
    protocol = "#{parsed_url.scheme}:"
    host = parsed_url.host

    search = remote_html.search("link[rel=canonical][href!='']")
    if search.length > 0
      canonical = search.attr('href').to_s
    else
      search = remote_html.search("meta[property='og:url'][value!=''],meta[property='twitter:url'][value!='']")
      if search.length > 0
        canonical = search.attr('value').to_s
      else
        canonical = false
      end
    end

    # this has a JS companion in app/models/page.coffee#parse_canonical()
    if canonical.blank?
      canonical = false
    # protocol relative url
    elsif canonical[0..1] == "//"
      canonical = "#{protocol}#{canonical}"
    # relative url
    elsif canonical[0] == "/"
      canonical = "#{protocol}//#{host}#{canonical}"
    # sniff test for mangled urls
    elsif !canonical.include?("//") or
    # sniff test for urls on a different root domain
    !canonical.include?(domain)
      canonical = false
    end

    canonical
  end

  def populate_remote_data
    self.url = remote_normalized_url
    self.head_tags = remote_head_tags
    self.title = title_tag
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
      :link_tags => link_tags,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end
end
