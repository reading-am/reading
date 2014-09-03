class Page < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  has_one  :describe_data, dependent: :destroy # also handled by foreign key
  has_many :posts, dependent: :destroy # also handled by foreign key
  has_one  :readability_data, dependent: :destroy # also handled by foreign key
  has_many :users, through: :posts
  has_many :comments, dependent: :destroy # also handled by foreign key

  validates_presence_of :url, :domain, :medium
  validates_associated :domain
  validates_uniqueness_of :url

  # Don't use before_create here because we want populate_domain
  # to fire after the url might have changed but before validation
  before_validation :populate_describe_data, if: :new_record?
  before_validation :populate_domain, if: :url_changed?
  before_validation :populate_medium

private

  # This is a fallback to make sure every Page has a medium,
  # even if Describe fails
  def populate_medium
    if medium.blank?
      type = MIME::Types.type_for(Addressable::URI.parse(url).path).first
      type = type.blank? ? 'text' : type.media_type
      case type
      when 'audio', 'video', 'image', 'text'
        self.medium = type
      when 'model', 'multipart'
        self.medium = 'multi'
      else
        self.medium = 'text'
      end
    end
  end

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

    # Root paths should have a trailing /
    parsed_url.path = "/" if parsed_url.path === ""

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
      dd = DescribeData.new page: page
      dd.fetch
      # Now search again
      if !dd.response.blank? and dd.valid?
        page.describe_data = dd
        found = where(url: dd.response["url"]).first
      end
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
      page.assign_attributes attributes
      page.save
    end
    page
  end

  # this has a JS companion in bookmarklet/real_init.rb#get_title()
  def display_title
    title.blank? ? url : Sanitize.clean(title)
  end

  def display_description
    Sanitize.clean description
  end

  def proxy_embed
    if embed.blank?
      embed
    else
      e = embed
      e.gsub!(/(<img [^>]*src=["'])(.+?)(["'])/i) do
        Regexp.last_match[1] +
        "https://#{ENV['READING_IMG_SERVER']}#{Thumbor::Cascade.new(Regexp.last_match[2]).generate}" +
        Regexp.last_match[3]
      end
      # Make all embeds secure, even if they aren't (better to fail on https than http)
      # but don't replace the http in images that are proxied
      e.gsub!(/('|")http:\/\//, '\1https://')
    end
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

  def has_describe_data
    # When DD is first saved, the counter cache won't have been
    # updated in the model in memory so use loaded as a sign
    (
     association(:describe_data).loaded? and
     !describe_data.blank? and # it can be loaded but nil
     !describe_data.new_record? and
     !describe_data.destroyed?
    ) or
    read_attribute(:has_describe_data) > 0
  end

  def populate_describe_data html=nil
    # incurs a db query so cache result
    was_blank = describe_data.blank? || describe_data.destroyed?

    # This will create our DD if we just assigned it or
    # if it was assigned through find_or_create_by_url
    dd = was_blank ? DescribeData.new : describe_data
    dd.page = self

    # If we haven't already queried for the data...
    if dd.response.blank?
      html.blank? ? dd.fetch : dd.parse(html)
    end

    if !dd.response.blank?
      self.url = dd.response["url"]
      self.title = dd.response["title"]
      self.medium = dd.response["medium"]
      self.media_type = dd.response["media_type"]
      self.description = dd.response["description"]
      self.embed = dd.response["embed"]

      # Make sure the DD is valid, otherwise leave it off
      # so that the Page will still save if Describe is down.
      # If you try to reassign DD at this point, even if it's the same one,
      # rails will throw a frozen hash error. If there wasn't a DD already
      # and the Page isn't new_record? then ActiveRecord will auto save the
      # DD to the page.
      self.describe_data = dd if dd.valid? and was_blank
    end
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
      :embed          => proxy_embed,
      :medium         => medium,
      :media_type     => media_type,
      :description    => display_description,
      :posts_count    => posts_count,
      :comments_count => comments_count,
      :has_describe_data => has_describe_data,
      :created_at     => created_at,
      :updated_at     => updated_at
    }
  end
end
