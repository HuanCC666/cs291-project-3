class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  
  has_one :expert_profile, dependent: :destroy
  after_create :create_expert_profile_automatically

  def as_json(options = {})
    {
      id: id,
      username: username,
      createdAt: created_at&.iso8601,
      lastActiveAt: last_active_at&.iso8601
    }
  end

  private

  def create_expert_profile_automatically
    create_expert_profile
  end
end