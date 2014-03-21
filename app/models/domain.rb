class Domain < ActiveRecord::Base

  has_many :pages, dependent: :destroy
  has_many :posts, through: :pages
  has_many :users, through: :pages

  validates_presence_of :name
  validates_format_of :name, /\w\.[a-z]/i
  validates_uniqueness_of :name, case_sensitive: false

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
