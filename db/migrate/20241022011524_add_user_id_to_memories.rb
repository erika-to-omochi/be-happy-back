class AddUserIdToMemories < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:memories, :user_id)
      Memory.where(user_id: nil).update_all(user_id: 1)
      add_reference :memories, :user, null: false, foreign_key: true
    end
  end
end
