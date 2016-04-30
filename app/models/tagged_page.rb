class TaggedPage < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :page, counter_cache: true
  belongs_to :tag, counter_cache: true

  validates :user_id, presence: true
  validates :page_id, presence: true
  validates :tag_id, presence: true
end
