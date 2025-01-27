class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :email,              null: false
        t.string :encrypted_password, null: false

        t.string   :reset_password_token
        t.datetime :reset_password_sent_at

        t.datetime :remember_created_at

        t.timestamps null: false
      end

      add_index :users, :email, unique: true
      add_index :users, :reset_password_token, unique: true
    end
  end
end
