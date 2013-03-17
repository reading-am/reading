class DowncaseDomainNames < ActiveRecord::Migration
  def up
    execute("UPDATE domains SET name = LOWER(name)")
  end

  def down
  end
end
