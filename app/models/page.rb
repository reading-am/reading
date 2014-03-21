class Page < ActiveRecord::Base

  serialize :headers, JSON
  serialize :oembed, JSON

  belongs_to :domain, counter_cache: true
  has_one  :describe_data, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :comments, dependent: :destroy

  validates_presence_of :url, :domain
  validates_associated :domain
  validates_uniqueness_of :url

  before_validation :populate_domain
  after_create :populate_remote_data

private

  def populate_domain
    a = Addressable::URI.parse(url)
    # make sure the domain at least includes a period
    # and that it uses a valid protocol
    if !a.host.blank? && a.host.include?('.') && (a.scheme.blank? || ['http','https'].include?(a.scheme))
      self.domain = Domain.where(name: a.host).first_or_create
    end
  end

public

  def self.cleanup_url(url)
    # the protocol will be missing its second slash if it's been pulled from the middle of a url
    if !/^\w+:\/\w/.match(url).blank?
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
    # look for a cleaned up url
    if page = where(url: url).first
      page
    else
      # If nothing was found, send the url to Describe
      # where it will be cleaned up further
      page = self.new url: url
      page.describe_data = DescribeData.new page: page
      page.describe_data.fetch
      # Now search again
      found = where(url: page.describe_data.response["url"]).first
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
    title.blank? ? url : title
  end

  def wrapped_url
    "#{ROOT_URL}/#{self.url}"
  end

  def verb
    case medium
    when "audio"
      "listening to"
    when "video"
      "watching"
    when "image", "mutli"
      "looking at"
    else
      "reading"
    end
  end

  def imperative
    verb.split(' ')[0][0..-4]
  end

  def populate_remote_data
    # This will create our DD if we just assigned it or
    # if it was assigned through find_or_create_by_url
    self.describe_data = DescribeData.new(page: self) if describe_data.blank?
    describe_data.save if describe_data.changed?
    # fetch happens during save, after which we get access to these attributes
    self.url = describe_data.response["url"]
    self.title = describe_data.response["title"]
    self.medium = describe_data.response["medium"]
    self.media_type = describe_data.response["media_type"]
    self.description = describe_data.response["description"]
    self.embed = describe_data.response["embed"]
    save
  end

  def channels
    [
      "pages"
    ]
  end

  def simple_obj to_s=false
    {
      :type           => 'Page',
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

  ##################
  # REMOVE AFTER DDD
  ##################
  has_one :readability_data, dependent: :destroy

  META_TAG_NAMESPACES = ['og','twitter']

  # initialize the parsed tag cache
  after_initialize do |page|
    page.head_tags = page.head_tags
  end

  def mimetype
    if headers
      m = MIME::Types[headers['content-type'].split(';')[0]]
    else
      m = MIME::Types.type_for url
    end
    m[0] || MIME::Types['text/html'][0]
  end

  def html?
    mimetype.sub_type == "html"
  end

  def title_migration
    if !trans_tags("title").blank?
      trans_tags("title")
    elsif !title.blank?
      title
    elsif !r_title.blank? and r_title != "(no title provided)"
      r_title
    end
  end

  def media_type_migration
    if !meta_tags['og']['type'].blank?
      meta_tags['og']['type']
    elsif ['app','product'].include? meta_tags['twitter']['card']
      meta_tags['twitter']['card']
    else
      nil
    end
  end

  def image_migration
    mimetype.media_type == "image" ? url : trans_tags("image")
  end

  def embed_migration
    if !oembed.blank? && oembed['html']
      oembed['html']
    elsif trans_tags("player") || trans_tags("video")
      param = trans_tags("player") ? "player" : "video"
      "<iframe width=\"#{trans_tags("#{param}:width")}\" height=\"#{trans_tags("#{param}:height")}\" src=\"#{trans_tags("#{param}:secure_url") || trans_tags(param)}\"></iframe>"
    elsif !oembed.blank? && oembed['type'] == "photo"
      "<img width=\"#{oembed['width']}\" height=\"#{oembed['height']}\" src=\"#{oembed['url']}\">"
    elsif mimetype.media_type == "image"
      "<img src=\"#{url}\">"
    elsif meta_tags['twitter']['card'] == "photo"
      "<img width=\"#{meta_tags['twitter']["image:width"]}\" height=\"#{meta_tags['twitter']['image:height']}\" src=\"#{meta_tags['twitter']['image']}\">"
    # elsif meta_tags['twitter']['card'] == "gallery"
    #   i = 0
    #   imgs = []
    #   while !meta_tags['twitter']["image#{i}"].blank?
    #     imgs.push "<img src=\"#{meta_tags['twitter']["image#{i}"]}\">"
    #     i += 1
    #   end
    #   imgs.join("\n")
    else
      nil
    end
  end

  def excerpt_migration
    r_excerpt.gsub(/(&nbsp;|\s|&#13;|\r|\n)+/, " ") unless r_excerpt.blank?
  end

  def description_migration
    if !trans_tags("description").blank?
      trans_tags("description")
    else
      r_excerpt
    end
  end
  
  def keywords_migration
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
      m = k if media_type == k or
            v.include?(media_type) or
            (meta_tags['og']['type'] and v.include?(meta_tags['og']['type'].split(':').last))
    end
    m
  end

  def head_tags=(str_or_nodes)
    # clear the parsed tags
    @tag_cache = {}
    # PG will throw an error on some pages if you don't explicitly encode UTF-8
    # example: http://www-nc.nytimes.com/2009/09/11/world/americas/11hippo.html
    # fix from: http://stackoverflow.com/a/8873922/313561
    self[:head_tags] = str_or_nodes.to_s.encode(Encoding::UTF_16, Encoding::UTF_8, :invalid => :replace, :replace => '').encode(Encoding::UTF_8, Encoding::UTF_16)
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
          if ['og','twitter'].include? key
            # account for sites that have a meta tag named "og" or "twitter" along side subtags like "twitter:name"
            @tag_cache[:meta_tags][key]["root"] = val
          elsif key.match(regex)
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
  
end
