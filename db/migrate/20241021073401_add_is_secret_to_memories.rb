class AddIsSecretToMemories < ActiveRecord::Migration[7.0]
  def change
    add_column :memories, :is_secret, :boolean
  end
end
