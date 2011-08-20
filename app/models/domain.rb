class Domain < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :posts, :through => :pages
  has_many :users, :through => :pages

  validates_presence_of :name

  after_initialize :init

  def to_param
    name
  end

  def init
    self.verb ||= 'reading'
  end
end
