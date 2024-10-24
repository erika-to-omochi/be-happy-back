class AllowNullUserIdInMemories < ActiveRecord::Migration[7.0]
  def change
    change_column_null :memories, :user_id, true
  end
end