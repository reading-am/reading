class Comment < ApplicationRecord
  include Twitter::Extractor
  include Twitter::Autolink

  belongs_to :user, counter_cache: true
  belongs_to :page, counter_cache: true
  belongs_to :post, counter_cache: true
  belongs_to :parent, class_name: 'Comment',
                      foreign_key: :comment_id
  has_many   :children, class_name: 'Comment',
                      foreign_key: :comment_id

  validates_presence_of :user_id, :page_id, :body
  validate :post_belongs_to_user

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

  def mentioned_usernames
    @mentioned_usernames ||= extract_mentioned_screen_names body || []
  end

  def mentioned_emails
    # Taken from: http://www.regular-expressions.info/email.html
    # This has a ruby companion in constants.coffee.rb
    @mentioned_emails ||= body.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) || []
  end

  def mentioned_users
    User.where("lower(username) IN (:usernames) OR lower(email) IN (:emails)", {
      :usernames => mentioned_usernames.map{|u| u.downcase },
      :emails => mentioned_emails.map{|u| u.downcase }
    })
  end

  def mentions
    mentioned_usernames + mentioned_emails
  end

  def hashtags
    @hashtags ||= extract_hashtags body
  end

  def urls
    @urls ||= extract_urls body
  end

  def is_a_show
    m = mentioned_usernames.join("@")
    m = "@#{m}" if m.length > 0
    m += mentioned_emails.join
    return @is_a_show ||= (m.length > 0 and body.gsub(/\s|,/, '').length == m.length)
  end

  def channels
    [
      "comments",
      "pages.#{page_id}.comments"
    ]
  end

  ### This method is mirrored in comment.coffee
  def body_html
    html = html_escape(body)
    # nl2br
    html.gsub!(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/, "\\1<br>\\2")
    # wrap code
    html.gsub!(/`((?:[^`]+|\\.)*)`/) {|s| s.scan("\n").blank? ? "<code>#{s[1..-2]}</code>" : "<pre><code>#{s[1..-2]}</code></pre>" }
    # italicize quotes
    html.gsub!(/&quot;.*&quot;/, "<i>\\&</i>")
    # link emails
    html.gsub!(/(([a-z0-9*._+]){1,}\@(([a-z0-9]+[-]?){1,}[a-z0-9]+\.){1,}([a-z]{2,4}|museum)(?![\w\s?&.\/;#~%"=-]*>))/, "<a href=\"mailto:\\1\">\\1</a>")
    # wrap links and @mentions
    html = auto_link(html, {
      :url_class => 'r_url',
      :username_class => 'user',
      :username_url_base => "#{ROOT_URL}/",
      :hashtag_url_base => "#{ROOT_URL}/search?q="
    })
    # embed images
    html.gsub!(/(<a.*)( class="r_url" )(.*>)(.*\.(jpg|jpeg|png|gif).*)<\/a>/, "\\1 class=\"r_url r_image\" \\3<img src=\"\\4\"></a>")

    html.html_safe
  end
end
