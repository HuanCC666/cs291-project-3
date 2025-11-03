class Conversation < ApplicationRecord
  belongs_to :initiator, class_name: "User"
  belongs_to :assigned_expert, class_name: "User", optional: true
  has_many :messages, dependent: :destroy

  def as_json(options = {})
    {
      id: id.to_s,
      title: title,
      status: status,
      questionerId: initiator_id.to_s,
      questionerUsername: initiator.username,
      assignedExpertId: assigned_expert_id&.to_s,
      assignedExpertUsername: assigned_expert&.username,
      createdAt: created_at&.iso8601,
      updatedAt: updated_at&.iso8601,
      lastMessageAt: (last_message_at || created_at)&.iso8601,
      unreadCount: 0  # TODO: implement actual unread count logic
    }
  end
end
