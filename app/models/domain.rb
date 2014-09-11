class Domain < ActiveRecord::Base

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

  def simple_obj to_s=false
    {
      type: 'Domain',
      id: to_s ? id.to_s : id,
      name: name,
      verb: verb,
      pages_count: pages_count,
      created_at: created_at,
      updated_at: updated_at
    }
  end

end
