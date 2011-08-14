class Domain < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :posts, :through => :pages, :dependent => :destroy
  has_many :users, :through => :pages

  validates_presence_of :name

  def to_param
    name
  end
end
