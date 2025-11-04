class ConversationsController < ApplicationController
  before_action :require_session_or_jwt!
  

  # GET /conversations
  def index
    # Only return conversations where the current user is the initiator (questioner)
    # Conversations where the user is assigned as an expert should be accessed via /expert/queue
    conversations = Conversation.where(initiator_id: current_user.id)
    render json: conversations
  end

  # GET /conversations/:id
  def show
    conversation = Conversation.find_by(id: params[:id])
    
    # Check if user has access to this conversation
    # Users can access conversations if they are:
    # 1. The initiator of the conversation
    # 2. The assigned expert
    is_initiator = conversation && conversation.initiator_id == current_user.id
    is_assigned_expert = conversation && conversation.assigned_expert_id == current_user.id
    
    if is_initiator || is_assigned_expert
      render json: conversation
    else
      render json: { error: 'Conversation not found or not authorized' }, status: :not_found
    end
  end

  # POST /conversations
  def create
    conversation = Conversation.new(
      initiator_id: current_user.id,
      assigned_expert_id: params[:assigned_expert_id],
      title: params[:title] 
    )

    if conversation.save
      render json: conversation, status: :created
    else
      render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end
end