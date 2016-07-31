class Blockage < ApplicationRecord
  # these counter_caches sound backward semantically but they're not
  belongs_to :blocker, class_name: "User", counter_cache: :blocking_count
  belongs_to :blocked, class_name: "User", counter_cache: :blockers_count

  validates :blocker_id, presence: true
  validates :blocked_id, presence: true
end
