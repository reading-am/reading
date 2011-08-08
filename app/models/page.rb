class Page < ActiveRecord::Base
  belongs_to :domain
  has_many :posts
  has_many :users, :through => :posts

  validates_presence_of :url, :title

  before_create { parse_domain }

  def parse_domain
    self.domain  = Domain.find_or_create_by_name(URI.parse(self.url).host)
  end
end
