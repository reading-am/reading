class Post < ActiveRecord::Base

  belongs_to      :user, counter_cache: true
  belongs_to      :page, counter_cache: true
  has_one         :domain, through: :page
  has_many        :comments, dependent: :nullify  # intentionally not dependent destroy here, have it on pages and users
  has_many        :referring_posts, class_name: 'Post',
                                    foreign_key: 'referrer_post_id',
                                    dependent: :nullify
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

  searchable do
    boolean :yn
    integer :user_id
    text :page_title do
      page.title
    end
    text :page_url do
      page.url
    end
    text :page_content do
      if page.readability_data
        Sanitize.clean page.readability_data.content rescue nil
      end
    end
  end
  handle_asynchronously :solr_index

  skeleton :columns => [:id, :yn, :created_at, :updated_at],
           :assocs  => [:user, :page]

  private

  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id",
          { :user_id => user })
    .order("created_at DESC")
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
  def self.wrapped_url id, url, token=false
    url = "#{ROOT_URL}"
    url += "/t/#{token}" if token
    url += "/p/#{Base58.encode(id)}/#{url}"
  end

  def wrapped_url token=false
    self.class.wrapped_url id, page.url, token
  end

  def short_url
    "#{SHORT_DOMAIN}/p/#{Base58.encode(self.id)}"
  end

  def channels
    [
      "posts",
      "pages.#{page_id}.posts",
      "users.#{user.id}.posts"
    ].concat [user.id].concat(user.followers.where(:feed_present => true).pluck(:id)).map{|id| "users.#{id}.feed"}
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

  def self.simple_obj attrs
    {
      'type'   => name,
      'id'     => attrs['id'],
      'title'  => attrs['page']['title'],
      'url'    => attrs['page']['url'],
      'yn'     => attrs['yn'],
      'wrapped_url' => wrapped_url(attrs['id'], attrs['page']['url']),
      'created_at' => attrs['created_at'],
      'updated_at' => attrs['updated_at'],
      'referrer_post' => {
        'type' => 'Post',
        'id' => '',
        'user' => {
          'type' => 'User',
          'id' => '',
          'username' => '',
          'display_name' => '',
          'url' => ''
        }
      }
      #'referrer_post' => {
        #:type => "Post",
        #:id => has_ref ? (to_s ? referrer_post.id.to_s : referrer_post.id) : '',
        #:user => {
          #:type         => "User",
          #:id           => has_ref ? (to_s ? referrer_post.user.id.to_s : referrer_post.user.id) : '',
          #:username     => has_ref ? referrer_post.user.username : '',
          #:display_name => has_ref ? referrer_post.user.display_name : '',
          #:url          => has_ref ? referrer_post.user.url : ''
        #}
      #}
    }
  end
end
