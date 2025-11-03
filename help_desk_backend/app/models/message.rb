class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  validates :content, presence: true
  validates :sender_role, inclusion: { in: %w[initiator expert] }
  
  def read?
    is_read
  end

  def as_json(options = {})
    {
      id: id.to_s,
      conversationId: conversation_id.to_s,
      senderId: sender_id.to_s,
      senderUsername: sender.username,
      senderRole: sender_role,
      content: content,
      timestamp: created_at&.iso8601,
      isRead: is_read
    }
  end
end