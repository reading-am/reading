class Relationship < ApplicationRecord
  # these counter_caches sound backward semantically but they're not
  belongs_to :follower, class_name: "User", counter_cache: :following_count
  belongs_to :followed, class_name: "User", counter_cache: :followers_count

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
