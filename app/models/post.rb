class Post < ActiveRecord::Base

  belongs_to      :user, counter_cache: true
  belongs_to      :page, counter_cache: true
  has_one         :domain, through: :page
  has_many        :comments, dependent: :nullify # also handled by foreign key # intentionally not dependent destroy here, have it on pages and users
  has_many        :referring_posts, class_name: 'Post',
                                    foreign_key: 'referrer_post_id',
                                    dependent: :nullify # also handled by the foreign key

  belongs_to      :referrer_post, class_name: 'Post',
                                  counter_cache: :referring_posts_count

  validates_presence_of :user_id, :page_id

  # Return posts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  # For digest. All posts from a users feed that they haven't read
  scope :unread_by_since, lambda { |user, datetime| unread_since(user, datetime) }
  # Used to check for duplicate entries
  scope :recent_by_user_and_page, lambda { |user, page, time=1.day.ago| where("user_id = ? and page_id = ? and created_at > ?", user, page, time) }

  # for will_paginate
  self.per_page = 100

  private

  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("posts.user_id IN (#{following_ids}) OR posts.user_id = :user_id",
          { :user_id => user })
    .order("posts.created_at DESC")
  end

  def self.unread_since(user, datetime)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    read_page_ids = %(SELECT page_id FROM posts
                      WHERE user_id = :user_id AND created_at >= :datetime)
    where("user_id IN (#{following_ids}) AND created_at >= :datetime AND page_id NOT IN (#{read_page_ids})",
          { :user_id => user, :datetime => datetime })
    .order("created_at DESC")
  end

  public

  #TODO consider moving this to a view helper
  def wrapped_url(token=false)
    # This is intentionally http, not https
    url = "http://#{DOMAIN}"
    url += "/t/#{token}" if token
    url += "/p/#{Base58.encode(self.id)}/#{self.page.url}"
  end

  def short_url
    "#{SHORT_DOMAIN}/p/#{Base58.encode(self.id)}"
  end

  def channels
    [
      "posts",
      "pages.#{page_id}.posts",
      "users.#{user.id}.posts"
    ].concat [user.id].concat(user.followers.where(:feed_present => true).pluck(:id)).map{|id| "users.#{id}.following.posts"}
  end

  def simple_obj to_s=false
    has_ref = !referrer_post.nil?
    {
      :type   => "Post",
      :id     => to_s ? id.to_s : id,
      :title  => page.display_title,
      :url    => page.url,
      :yn     => yn,
      :wrapped_url => wrapped_url,
      :created_at => created_at,
      :updated_at => updated_at,
      :user => user.simple_obj(to_s),
      :page => page.simple_obj(to_s),
      :referrer_post => {
        :type => "Post",
        :id => has_ref ? (to_s ? referrer_post.id.to_s : referrer_post.id) : '',
        :user => {
          :type         => "User",
          :id           => has_ref ? (to_s ? referrer_post.user.id.to_s : referrer_post.user.id) : '',
          :username     => has_ref ? referrer_post.user.username : '',
          :display_name => has_ref ? referrer_post.user.display_name : '',
          :url          => has_ref ? referrer_post.user.url : ''
        }
      }
    }
  end
end
