class Domain < ApplicationRecord

  has_many :pages, dependent: :destroy # also handled by foreign key
  has_many :posts, through: :pages
  has_many :users, through: :pages

  validates :name, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\w\.[a-z]/i }

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
