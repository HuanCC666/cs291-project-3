class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :title, null: false
      t.string :status, null: false, default: "waiting"
      t.references :initiator, null: false, foreign_key: { to_table: :users }
      t.references :assigned_expert, null: true, foreign_key: { to_table: :users }
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, :status
    add_index :conversations, :last_message_at
  end
end
