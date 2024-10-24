class AddNameToMemories < ActiveRecord::Migration[7.0]
  def change
    add_column :memories, :name, :string
  end
end
