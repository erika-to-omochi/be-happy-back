class CreateMemories < ActiveRecord::Migration[7.0]
  def change
    create_table :memories do |t|
      t.text :content
      t.timestamps
    end
  end
end
