class Post < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :page
  has_one     :domain, :through => :page
  # has_many    :referring_posts
  # has_one     :reference_post

  validates_presence_of :user, :page

  def wrapped_url
    "http://0.0.0.0:3000/p/#{Base58.encode(self.id)}/#{self.page.url}"
  end
end
