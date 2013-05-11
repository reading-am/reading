class Domain < ActiveRecord::Base
  include IdentityCache

  has_many :pages, :dependent => :destroy
  has_many :posts, :through => :pages
  has_many :users, :through => :pages

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  oriental :vertex,
    :attributes => [:name],
    :in => [:pages]

  def to_param
    name
  end

  def name=(name)
    self[:name] = name.downcase
  end

  def self.find_by_name(name)
    where("name = ?", name.downcase).limit(1).first
  end

  def verb
    # from: http://stackoverflow.com/questions/373731/override-activerecord-attribute-methods
    read_attribute(:verb) || 'reading'
  end

end
