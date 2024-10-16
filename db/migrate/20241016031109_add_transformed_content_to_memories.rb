class AddTransformedContentToMemories < ActiveRecord::Migration[7.0]
  def change
    add_column :memories, :transformed_content, :text
  end
end
