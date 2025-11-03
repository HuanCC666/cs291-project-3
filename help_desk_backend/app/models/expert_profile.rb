class ExpertProfile < ApplicationRecord
  belongs_to :user

  def as_json(options = {})
    {
      id: id.to_s,
      userId: user_id.to_s,
      bio: bio,
      knowledgeBaseLinks: knowledge_base_links || [],
      createdAt: created_at&.iso8601,
      updatedAt: updated_at&.iso8601
    }
  end
end
