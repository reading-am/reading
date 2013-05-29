class Blog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :template
end
