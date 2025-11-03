class ConversationsController < ApplicationController
  before_action :require_session_or_jwt!
  

  # GET /conversations
  def index
    conversations = Conversation.where(
      "initiator_id = ? OR assigned_expert_id = ?", current_user.id, current_user.id
    )
    render json: conversations
  end

  # GET /conversations/:id
  def show
    conversation = Conversation.find_by(id: params[:id])
    
    # Check if user has access to this conversation
    # Users can access conversations if they are:
    # 1. The initiator of the conversation
    # 2. The assigned expert
    # 3. An expert viewing a waiting conversation (to decide whether to claim)
    is_initiator = conversation && conversation.initiator_id == current_user.id
    is_assigned_expert = conversation && conversation.assigned_expert_id == current_user.id
    is_expert_viewing_waiting = conversation && conversation.status == 'waiting' && ExpertProfile.exists?(user_id: current_user.id)
    
    if is_initiator || is_assigned_expert || is_expert_viewing_waiting
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