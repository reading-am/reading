class AddReadabilityToPages < ActiveRecord::Migration
  def change
    add_column :pages, :readability, :text
  end
end
