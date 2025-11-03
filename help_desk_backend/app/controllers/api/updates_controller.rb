class Api::UpdatesController < ApplicationController
  before_action :authenticate_jwt!

  # GET /api/conversations/updates
  # Query params: userId (required), since (optional, ISO 8601 timestamp)
  def conversations
    user_id = params[:userId]
    since = params[:since]

    # Validate user_id
    unless user_id
      return render json: { error: 'userId parameter is required' }, status: :bad_request
    end

    # Get conversations where the user is initiator (questioner)
    # Conversations where the user is assigned as an expert are handled by /api/expert-queue/updates
    query = Conversation.where(initiator_id: user_id)

    # Filter by timestamp if provided
    if since.present?
      begin
        since_time = Time.iso8601(since)
        query = query.where("updated_at > ?", since_time)
      rescue ArgumentError
        return render json: { error: 'Invalid timestamp format. Use ISO 8601 format.' }, status: :bad_request
      end
    end

    conversations = query.order(updated_at: :desc)
    render json: conversations
  end

  # GET /api/messages/updates
  # Query params: userId (required), since (optional, ISO 8601 timestamp)
  def messages
    user_id = params[:userId]
    since = params[:since]

    # Validate user_id
    unless user_id
      return render json: { error: 'userId parameter is required' }, status: :bad_request
    end

    # Get conversations where the user is involved
    # This includes both conversations as initiator and as assigned expert
    # because users need to receive message updates for conversations they're actively participating in
    conversation_ids = Conversation.where(
      "initiator_id = ? OR assigned_expert_id = ?", user_id, user_id
    ).pluck(:id)

    # Get messages from those conversations
    query = Message.where(conversation_id: conversation_ids)

    # Filter by timestamp if provided
    if since.present?
      begin
        since_time = Time.iso8601(since)
        query = query.where("created_at > ?", since_time)
      rescue ArgumentError
        return render json: { error: 'Invalid timestamp format. Use ISO 8601 format.' }, status: :bad_request
      end
    end

    messages = query.order(created_at: :asc)
    render json: messages
  end

  # GET /api/expert-queue/updates
  # Query params: expertId (required), since (optional, ISO 8601 timestamp)
  # Note: Expert queue returns the complete queue state, not incremental updates.
  # The 'since' parameter can be used by the client for caching/optimization,
  # but we still return all conversations to ensure the expert sees the complete queue.
  def expert_queue
    expert_id = params[:expertId]
    since = params[:since]

    # Validate expert_id
    unless expert_id
      return render json: { error: 'expertId parameter is required' }, status: :bad_request
    end

    # Validate timestamp format if provided
    if since.present?
      begin
        Time.iso8601(since)
      rescue ArgumentError
        return render json: { error: 'Invalid timestamp format. Use ISO 8601 format.' }, status: :bad_request
      end
    end

    # Get all waiting conversations (not filtered by time)
    # Expert queue should show ALL waiting conversations at any given time
    waiting = Conversation.where(status: 'waiting').order(created_at: :asc)
    
    # Get all conversations assigned to this expert (not filtered by time)
    assigned = Conversation.where(assigned_expert_id: expert_id, status: 'active').order(updated_at: :desc)

    render json: {
      waitingConversations: waiting.as_json,
      assignedConversations: assigned.as_json
    }
  end
end