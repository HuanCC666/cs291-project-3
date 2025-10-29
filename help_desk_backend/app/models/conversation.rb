class Conversation < ApplicationRecord
  belongs_to :initiator
  belongs_to :assigned_expert
end
