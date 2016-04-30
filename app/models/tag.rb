class Tag < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :page, counter_cache: true

  validates :name, presence: true
  validates :user_id, presence: true
  validates :page_id, presence: true

  #strip_attributes only: [:name]
end
