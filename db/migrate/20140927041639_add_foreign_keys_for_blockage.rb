class AddForeignKeysForBlockage < ActiveRecord::Migration
  def change
    add_foreign_key "blockages", "users", name: "blockages_blocked_id_fk", column: "blocked_id", dependent: :delete
    add_foreign_key "blockages", "users", name: "blockages_blocker_id_fk", column: "blocker_id", dependent: :delete
  end
end
