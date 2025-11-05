class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  
  has_one :expert_profile, dependent: :destroy

  def as_json(options = {})
    {
      id: id,
      username: username,
      createdAt: created_at&.iso8601,
      lastActiveAt: last_active_at&.iso8601
    }
  end
end