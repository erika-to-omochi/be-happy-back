class AddUserIdToMemories < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:memories, :user_id)
      add_reference :memories, :user, null: false, foreign_key: true
    end
  end
end
