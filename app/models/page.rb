class Page < ActiveRecord::Base

  serialize :oembed, JSON

  belongs_to :domain, counter_cache: true
  has_one  :readability_data, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :comments, dependent: :destroy

  validates_presence_of :url, :domain
  validates_associated :domain
  validates_uniqueness_of :url

  cattr_accessor :crawl_timeout

  before_validation :populate_domain
  before_save :populate_medium
  before_create :populate_remote_page_data
  after_create :populate_remote_meta_data

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

  skeleton :columns => [:id, :url]

  META_TAG_NAMESPACES = ['og','twitter']

  # NOTE - properties prefixed with r_ (r_title, r_excerpt)
  # are from readability_data

private

  def populate_domain
    a = Addressable::URI.parse(url)
    # make sure the domain at least includes a period
    # and that it uses a valid protocol
    # TODO - move these checks into a validation
    if !a.host.blank? && a.host.include?('.') && (a.scheme.blank? || ['http','https'].include?(a.scheme))
      self.domain = Domain.find_or_create_by_name(a.host)
    end
  end

public

  # initialize the parsed tag cache
  after_initialize do |page|
    page.head_tags = page.head_tags
  end

  def self.cleanup_url(url)
    # the protocol will be missing its second slash if it's been pulled from the middle of a url
    if !/^https?:\/\w/.match(url).blank?
      url = url.sub(":/", "://")
    # add http if the url doesn't include a protocol
    elsif !url.include?("://") or (url.include?(".") and url.index("://") > url.index("."))
      url = "http://#{url}"
    end

    parsed_url = Addressable::URI.parse(url)

    # protocols and hosts aren't case sensitive: http://stackoverflow.com/questions/2148603/is-the-protocol-name-in-urls-case-sensitive
    parsed_url.scheme = parsed_url.scheme.downcase unless parsed_url.scheme.blank?
    parsed_url.host = parsed_url.host.downcase unless parsed_url.host.blank?

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
    attributes[:url] = self.cleanup_url attributes[:url]
    page = self.find_by_url(attributes[:url], true)
    if page.new_record?
      page.attributes = attributes.merge(page.attributes)
      page.save
    end
    page
  end

  # this has a JS companion in bookmarklet/real_init.rb#get_title()
  def display_title
    if !trans_tags("title").blank?
      trans_tags("title")
    elsif !title.blank?
      title
    elsif !r_title.blank? and r_title != "(no title provided)"
      r_title
    else
      url
    end
  end

  def media_type
    if !oembed.blank? && !oembed['type'].blank?
      oembed['type']
    elsif !meta_tags['og']['type'].blank?
      # http://ogp.me/#types
      # colon denotes a namespace, period a sub property
      meta_tags['og']['type'].split(':').last.split('.').first
    elsif !meta_tags['medium'].blank? # flickr uses this
      meta_tags['medium'].blank?
    else
      false
    end
  end

  def image
    trans_tags("image")
  end

  def embed
    if medium != 'text'
      if !oembed.blank? && oembed['html']
        oembed['html']
      elsif trans_tags("player") || trans_tags("video")
        param = trans_tags("player") ? "player" : "video"
        "<iframe width=\"#{trans_tags("#{param}:width")}\" height=\"#{trans_tags("#{param}:height")}\" src=\"#{trans_tags(param)}\"></iframe>"
      elsif media_type == "photo"
        "<img src=\"#{image}\">"
      else
        nil
      end
    end
    # here's a sample :text embed should we decide to embed them
    # http://hapgood.us/2013/05/21/reply-to-cole-pushing-back-vs-pushing-forward/
  end

  def excerpt
    r_excerpt.gsub(/(&nbsp;|\s|&#13;|\r|\n)+/, " ") unless r_excerpt.blank?
  end

  def description
    if !trans_tags("description").blank?
      trans_tags("description")
    else
      excerpt
    end
  end

  def wrapped_url
    "#{ROOT_URL}/#{self.url}"
  end

  def keywords
    if !meta_tags['keywords'].blank?
      delimiter = meta_tags['keywords'].include?(',') ? ',' : ' '
      k = meta_tags['keywords'].split(delimiter)
      k.collect{|x| x.strip}
    else
      []
    end
  end

  def parse_medium
    mediums = {
      'audio' => ['music','song','album','sound'],
      'video' => ['video','movie'],
      'image' => ['photo'],
      'text'  => ['article','book','quote']
    }
    m = 'text' # default
    mediums.select! do |k,v|
      m = k if v.include?(media_type) or (meta_tags['og']['type'] and v.include?(meta_tags['og']['type'].split(':').last))
    end
    m
  end

  def verb
    if medium == 'audio'
      'listening to'
    elsif medium == 'video'
      'watching'
    elsif medium == 'image' or ['profile'].include?(media_type)
      'looking at'
    else
      'reading'
    end
  end

  def imperative
    verb.split(' ')[0][0..-4]
  end

  def head_tags=(str_or_nodes)
    # clear the parsed tags
    @tag_cache = {}
    # PG will throw an error on some pages if you don't explicitly encode UTF-8
    # example: http://www-nc.nytimes.com/2009/09/11/world/americas/11hippo.html
    # fix from: http://stackoverflow.com/a/8873922/313561
    self[:head_tags] = str_or_nodes.to_s.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16')
  end

  def head_tags
    @tag_cache ||= {}
    @tag_cache[:head_tags] ||= Nokogiri::HTML self[:head_tags]
  end

  def title_tag
    @tag_cache[:title_tag] ||= (head_tags.search('title').first.text rescue '')
  end

  def trans_tags name
    if !oembed.blank? and !oembed[name].blank?
      oembed[name]
    elsif !meta_tags["og"][name].blank?
      meta_tags["og"][name]
    elsif !meta_tags["twitter"][name].blank?
      meta_tags["twitter"][name]
    else !meta_tags[name].blank?
      meta_tags[name]
    end
  end

  # Relevant
  # http://www.metatags.org/all_metatags
  # http://en.wikipedia.org/wiki/Meta_element
  def meta_tags
    # this has a JS companion in bookmarklet/real_init.rb#get_meta_tags()
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

  def oembed_tags
    if @tag_cache[:oembed_tags].blank?
      @tag_cache[:oembed_tags] = {'json'=>false,'xml'=>false}
      head_tags.search('link[rel=alternate][type$=oembed]').each do |n|
        @tag_cache[:oembed_tags][n.attribute('type').to_s[/\/(.*)\+/,1]] = n.attribute('href').to_s
      end
    end
    @tag_cache[:oembed_tags]
  end

  def crawl_url
    a = Addressable::URI.parse(url)
    # check for a hashbang: https://developers.google.com/webmasters/ajax-crawling/docs/getting-started
    if !a.fragment.blank? && a.fragment[0] == '!'
      qv = a.query_values || {}
      qv['_escaped_fragment_'] = a.fragment[1..-1]
      a.query_values = qv
      a.fragment = nil
    end
    a.to_s
  end

  def mech=(obj)
    # this setter is used during testing
    @mech = obj
  end

  def mech
    if @mech.blank?
      agent = Mechanize.new
      agent.user_agent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" # via: http://support.google.com/webmasters/bin/answer.py?hl=en&answer=1061943
      agent.follow_meta_refresh = true
      if !crawl_timeout.blank?
        agent.open_timeout = agent.read_timeout = crawl_timeout
      end
      @mech = agent.get crawl_url
    end
    @mech
  end

  def remote_resolved_url
    mech.uri.to_s
  end

  def remote_normalized_url
    remote_canonical_url ? remote_canonical_url : self.class.cleanup_url(remote_resolved_url)
  end

  # this has a JS companion in bookmarklet/real_init.coffee#get_head_tags()
  def remote_head_tags
    mech.search('title,meta,link:not([rel=stylesheet])')
  end

  def remote_canonical_url
    parsed_url = Addressable::URI.parse(remote_resolved_url)
    domain = parsed_url.host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"
    protocol = "#{parsed_url.scheme}:"
    host = parsed_url.host

    # this has a JS companion in bookmarklet/real_init.coffee#get_url()
    search = mech.search("link[rel=canonical][href!='']")
    if search.length > 0
      canonical = search.attr('href').to_s
    else
      search = mech.search("meta[property='og:url'][value!=''],meta[property='twitter:url'][value!='']")
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

  def remote_oembed
    begin
      curl = Curl::Easy.new oembed_tags['json'] || oembed_tags['xml']
      curl.follow_location = true
      curl.useragent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" # via: http://support.google.com/webmasters/bin/answer.py?hl=en&answer=1061943
      curl.perform
      oembed_tags['json'] ? ActiveSupport::JSON.decode(curl.body_str) : Hash.from_xml(curl.body_str)['oembed']
    rescue
      begin
        OEmbed::Providers.register_all
        OEmbed::Providers.get(url).fields
      rescue
        nil
      end
    end
  end

  def populate_medium
    self.medium = parse_medium
  end

  def populate_remote_page_data
    self.url = remote_normalized_url
    self.head_tags = remote_head_tags
    self.title = title_tag
    return self
  end

  def populate_remote_meta_data
    self.oembed = remote_oembed

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

  def self.simple_obj attrs
    attrs
  end

  def simple_obj to_s=false
    {
      :type           => self.class.name,
      :id             => to_s ? id.to_s : id,
      :url            => url,
      :title          => display_title,
      :embed          => embed,
      :medium         => medium,
      :media_type     => media_type,
      :description    => description,
      :posts_count    => posts_count,
      :comments_count => comments_count,
      :created_at     => created_at,
      :updated_at     => updated_at
    }
  end
end
