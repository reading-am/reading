class Domain < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :posts, :through => :pages
  has_many :users, :through => :pages

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_param
    name
  end

  def verb
    # from: http://stackoverflow.com/questions/373731/override-activerecord-attribute-methods
    read_attribute(:verb) || 'reading'
  end

  def imperative
    self.verb.split(' ')[0][0..-4]
  end
end
