class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Twitter::Autolink

  belongs_to :user, :counter_cache => true
  belongs_to :page, :counter_cache => true
  belongs_to :post, :counter_cache => true
  belongs_to :parent, :class_name => 'Comment'
  has_many   :children, :class_name => 'Comment',
    :foreign_key => :parent_id

  validates_presence_of :user_id, :page_id, :body
  validate :post_belongs_to_user

  attr_accessible :body

  default_scope includes([:user,:page])
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

  def post_belongs_to_user
    if !post.blank? and post.user != user
      errors.add(:post, "must belong to the user")
    end
  end

  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id",
          { :user_id => user })
  end

  public

  def mentions
    extract_mentioned_screen_names body
  end

  def hashtags
    extract_hashtags body
  end

  def urls
    extract_urls body
  end

  def body_html
    html = html_escape(body)
    ### These methods are mirrored in the handlebars js helpers
    # nl2br
    html.gsub!(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/, "\\1<br>\\2")
    # email
    html.gsub!(/(([a-z0-9*._+]){1,}\@(([a-z0-9]+[-]?){1,}[a-z0-9]+\.){1,}([a-z]{2,4}|museum)(?![\w\s?&.\/;#~%"=-]*>))/, "<a href=\"mailto:\\1\">\\1</a>")
    # code
    html.gsub!(/`((?:[^`]+|\\.)*)`/) {|s| s.scan("\n").blank? ? "<code>#{s[1..-2]}</code>" : "<pre><code>#{s[1..-2]}</code></pre>" }
    # quotes
    html.gsub!(/&quot;.*&quot;/, "<i>\\&</i>")
    # links and @mentions
    html = auto_link(html, {
      :url_class => '',
      :username_class => 'user',
      :username_url_base => "http://#{DOMAIN}/",
      :hashtag_url_base => "http://#{DOMAIN}/search?q="
    })
    # images
    html.gsub!(/<a href="(.*\.(jpg|jpeg|png|gif).*)">.*<\/a>/, "<a href=\"\\1\"><img src=\"\\1\"></a>")

    html.html_safe
  end

  def simple_obj to_s=false
    {
      :type   => "Comment",
      :id     => to_s ? id.to_s : id,
      :body   => body,
      :url    => "http://#{DOMAIN}/#{user.username}/comments/#{id}",
      :created_at => created_at,
      :updated_at => updated_at,
      :user   => user.simple_obj,
      :page   => page.simple_obj
    }
  end
end
