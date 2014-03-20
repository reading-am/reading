class Page < ActiveRecord::Base

  serialize :headers, JSON
  serialize :oembed, JSON

  belongs_to :domain, counter_cache: true
  has_one  :describe_data, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :comments, dependent: :destroy

  # validates_presence_of :url, :domain
  # validates_associated :domain
  validates_uniqueness_of :url

  # before_validation :populate_domain
  # before_create :populate_remote_data

private

  def populate_domain
    a = Addressable::URI.parse(url)
    # make sure the domain at least includes a period
    # and that it uses a valid protocol
    # TODO - move these checks into a validation
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
    if page = where(url: url).limit(1).first
      page
    else
      page = self.new url: url
      # page.url = page.remote_normalized_url
      found = where(url: page.url).limit(1).first
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
    if !title.blank?
      title
    elsif !r_title.blank? and r_title != "(no title provided)"
      r_title
    else
      url
    end
  end

  def wrapped_url
    "#{ROOT_URL}/#{self.url}"
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

  def populate_remote_data
    dd = DescribeData.create :page => self
    self.r_title = dd.title
    self.r_excerpt = dd.excerpt
    self.save
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
end
