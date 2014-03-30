class AddfuzzystrmatchAndpgTrgmModules < ActiveRecord::Migration
  def up
    execute "create extension fuzzystrmatch"
    execute "create extension pg_trgm"
  end
end
