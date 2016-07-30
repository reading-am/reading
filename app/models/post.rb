class Post < ApplicationRecord
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
  scope :from_users_followed_by_including, lambda { |user| followed_by_including(user) }
  scope :from_domain, lambda { |domain| originating_from(domain) }
  # For digest. All posts from a users feed that they haven't read
  scope :unread_by_since, lambda { |user, datetime| unread_since(user, datetime) }
  # Used to check for duplicate entries
  scope :recent_by_user_and_page, lambda { |user, page, time=1.day.ago| where("user_id = ? and page_id = ? and created_at > ?", user, page, time) }

  after_commit on: :create do
    user.hooks.each { |hook| hook.run(self, 'new') }
    PusherJob.perform_later 'create', self
  end

  after_commit on: [:create, :update] do
    user.hooks.each { |hook| hook.run(self, yn ? 'yep' : 'nope') } if previous_changes['yn'] and !yn.nil?
    PusherJob.perform_later 'update', self unless previous_changes['id'] # new_record?
  end

  after_destroy do
    PusherJob.perform_later 'destroy', self
  end
  
  private

  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("posts.user_id IN (#{following_ids})",
          { :user_id => user })
    .order("posts.created_at DESC")
  end

  def self.followed_by_including(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("posts.user_id IN (#{following_ids}) OR posts.user_id = :user_id",
          { :user_id => user })
    .order("posts.created_at DESC")
  end

  def self.originating_from(domain)
    page_ids = %(SELECT id FROM pages
                 WHERE domain_id = :domain_id)
    where("posts.page_id IN (#{page_ids})",
          { domain_id: domain })
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

  # TODO: consider moving this to a view helper
  def wrapped_url(token = false)
    url = ROOT_URL
    url += "/t/#{token}" if token
    url + "/p/#{Base58.encode(id)}/#{page.url}"
  end

  def short_url
    "#{SHORT_DOMAIN}/p/#{Base58.encode(id)}"
  end

  def channels
    [
      'posts',
      "pages.#{page_id}.posts",
      "users.#{user.id}.posts"
    ].concat [user.id].concat(user.followers.where(:feed_present => true).pluck(:id)).map{|id| "users.#{id}.following.posts"}
  end
end
