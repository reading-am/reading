class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :page
  has_one     :domain, :through => :page
  has_many    :referring_posts, :class_name => 'Post',
    :foreign_key => 'referrer_post_id'
  belongs_to  :referrer_post, :class_name => 'Post'

  validates_presence_of :user, :page

  # Feed logic from: http://ruby.railstutorial.org/chapters/following-users#sec:the_status_feed
  default_scope :order => 'posts.created_at DESC'

  # Return posts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id",
          { :user_id => user })
  end

  public

  #TODO consider moving this to a view helper
  def wrapped_url(token=false)
    url = "http://#{DOMAIN}"
    url += "/t/#{token}" if token
    url += "/p/#{Base58.encode(self.id)}/#{self.page.url}"
  end

  def short_url
    "#{SHORT_DOMAIN}/p/#{Base58.encode(self.id)}"
  end

  def simple_obj to_s=false
    has_ref = !self.referrer_post.nil?
    {
      :type   => "Post",
      :id     => to_s ? self.id.to_s : self.id,
      :title  => self.page.title,
      :url    => self.page.url,
      :yn     => self.yn,
      :wrapped_url => self.wrapped_url,
      :user => {
        :id           => to_s ? self.user.id.to_s : self.user.id,
        :username     => self.user.username,
        :display_name => self.user.display_name
      },
      :referrer_post => {
        :id => has_ref ? (to_s ? self.referrer_post.id.to_s : self.referrer_post.id) : '',
        :user => {
          :id           => has_ref ? (to_s ? self.referrer_post.user.id.to_s : self.referrer_post.user.id) : '',
          :username     => has_ref ? self.referrer_post.user.username : '',
          :display_name => has_ref ? self.referrer_post.user.display_name : ''
        }
      }
    }
  end
end
