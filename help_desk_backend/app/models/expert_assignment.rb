class ExpertAssignment < ApplicationRecord
  belongs_to :conversation
  belongs_to :expert, class_name: 'User'

  def as_json(options = {})
    {
      id: id.to_s,
      conversationId: conversation_id.to_s,
      expertId: expert_id.to_s,
      status: status,
      assignedAt: assigned_at&.iso8601,
      resolvedAt: resolved_at&.iso8601,
      rating: nil  # TODO: implement rating feature if needed
    }
  end
end
