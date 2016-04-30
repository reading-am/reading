class Tag < ActiveRecord::Base
  has_many :tagged_pages, dependent: :destroy # also handled by foreign key
  has_many :pages, through: :tagged_pages
  has_many :users, through: :tagged_pages

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
