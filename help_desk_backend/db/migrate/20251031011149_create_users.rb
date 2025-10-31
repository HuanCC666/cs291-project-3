class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.datetime :last_active_at

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :last_active_at
  end
end
