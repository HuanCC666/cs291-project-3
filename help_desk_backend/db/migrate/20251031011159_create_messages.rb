class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.string :sender_role, null: false
      t.text :content, null: false
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]

    add_check_constraint :messages,
      "sender_role IN ('initiator', 'expert')",
      name: "messages_sender_role_check"
  end
end
