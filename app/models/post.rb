class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :page
  has_one     :domain, :through => :page
  has_many    :referring_posts, :class_name => 'Post',
    :foreign_key => 'referrer_post_id'
  belongs_to  :referrer_post, :class_name => 'Post'

  validates_presence_of :user, :page

  def wrapped_url
    "http://0.0.0.0:3000/p/#{Base58.encode(self.id)}/#{self.page.url}"
  end
end
