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
    if conversation && (conversation.initiator_id == current_user.id || conversation.assigned_expert_id == current_user.id)
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