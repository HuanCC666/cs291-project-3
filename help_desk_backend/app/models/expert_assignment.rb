class ExpertAssignment < ApplicationRecord
  belongs_to :conversation
  belongs_to :expert
end
