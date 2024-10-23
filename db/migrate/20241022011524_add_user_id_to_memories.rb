class AddUserIdToMemories < ActiveRecord::Migration[7.0]
  def change
    add_reference :memories, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        Memory.where(user_id: nil).update_all(user_id: 1)
        change_column_null :memories, :user_id, false
      end
    end
  end
end
