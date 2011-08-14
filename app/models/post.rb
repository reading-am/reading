class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :page
  has_one     :domain, :through => :page
  has_many    :referring_posts, :class_name => 'Post',
    :foreign_key => 'referrer_post_id'
  belongs_to  :referrer_post, :class_name => 'Post'

  validates_presence_of :user, :page

 default_scope :order => 'posts.created_at DESC'

  # Return microposts from the users being followed by the given user.
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
  def wrapped_url
    "http://reading.am/p/#{Base58.encode(self.id)}/#{self.page.url}"
  end
end
