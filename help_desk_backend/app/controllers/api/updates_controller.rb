class Api::UpdatesController < ApplicationController
  before_action :authenticate_jwt!

  # GET /api/updates/conversations
  def conversations
  end

  # GET /api/updates/messages
  def messages
  end

  # GET /api/updates/expert_queue
  def expert_queue
  end
end
