class DropReadabilityFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :readability
  end
end
