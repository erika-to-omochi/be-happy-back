class CreateGuestUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :guest_users do |t|
      t.string :session_id, null: false   # ゲストの識別に使用するセッションID
      t.timestamps
    end

    add_index :guest_users, :session_id, unique: true  # セッションIDに一意性を付与
  end
end
