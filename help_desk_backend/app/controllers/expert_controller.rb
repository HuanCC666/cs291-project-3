class ExpertController < ApplicationController
  before_action :authenticate_jwt!

  # GET /expert/queue
  def queue
  end

  # POST /expert/conversations/:conversation_id/claim
  def claim
  end

  # POST /expert/conversations/:conversation_id/unclaim
  def unclaim
  end

  # GET /expert/profile
  def profile
  end

  # PUT /expert/profile
  def update_profile
  end

  # GET /expert/assignments/history
  def assignments_history
  end
end
