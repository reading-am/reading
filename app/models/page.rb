class Page < ActiveRecord::Base
  belongs_to :domain
  has_many :posts
  has_many :users, :through => :posts

  validates_presence_of :url, :title

  before_create { parse_domain }

private

  def parse_domain
    self.domain  = Domain.find_or_create_by_name(Addressable::URI.parse(self.url).host)
  end

public

  def wrapped_url
    "http://0.0.0.0:3000/#{self.url}"
  end
end
