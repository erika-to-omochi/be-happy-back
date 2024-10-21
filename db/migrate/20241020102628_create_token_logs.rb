class CreateTokenLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :token_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.datetime :issued_at

      t.timestamps
    end
  end
end
