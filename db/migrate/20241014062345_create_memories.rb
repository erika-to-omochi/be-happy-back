class CreateMemories < ActiveRecord::Migration[7.0]
  def change
    create_table :memories do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
