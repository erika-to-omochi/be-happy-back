class AddTransformedContentToMemories < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:memories, :transformed_content)
      add_column :memories, :transformed_content, :text
    end
  end
end
