class Subscription < ActiveRecord::Base
  # a user is subscribed to comments or reads on a page
  # created_at is used for a cron job to query and delete old subscriptions
  attr_accessible :created_at, :type

  belongs_to :user
  belongs_to :page

  validates_format_of :type, :with => URI::regexp(%w(comments reads))
end
