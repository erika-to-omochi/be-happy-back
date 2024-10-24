class AddGuestUserIdToMemories < ActiveRecord::Migration[7.0]
  def change
    add_column :memories, :guest_user_id, :integer
    add_index :memories, :guest_user_id
  end
end
