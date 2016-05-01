class Tag < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :page, counter_cache: true

  validates :name, presence: true
  validates :user_id, presence: true
  validates :page_id, presence: true

  strip_attributes only: [:name]

  class << self
    def find_by(*args)
      return super(*args) unless Hash === args.first && args.first.key?(:name)
      new_args = args.first.dup
      name = new_args.delete(:name)
      where_name(name).where(new_args).take
    end

    def where_name(name)
      formatter = lambda { |c| "lower(trim(regexp_replace(#{c}, '\s+', '', 'g')))" }
      where("#{formatter.call('name')} = #{formatter.call('?')}", name)
    end
  end
end
