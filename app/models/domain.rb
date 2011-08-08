class Domain < ActiveRecord::Base
  has_many :posts
  has_many :pages
  has_many :users, :through => :posts

  validates_presence_of :name

  def to_param
    name
  end
end
