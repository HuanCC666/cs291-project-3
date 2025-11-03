class Api::UpdatesController < ApplicationController
  before_action :authenticate_jwt!

  # GET /api/conversations/updates
  def conversations
    render json: []
  end

  # GET /api/messages/updates
  def messages

    render json: []
  end

  # GET /api/expert-queue/updates
  def expert_queue

    render json: []
  end
end