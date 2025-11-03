class MessagesController < ApplicationController
  before_action :require_session_or_jwt!

  # GET /conversations/:conversation_id/messages
  def index
    conversation = Conversation.find_by(id: params[:conversation_id])
    
    # Check if user has access to this conversation
    # Users can access messages if they are:
    # 1. The initiator of the conversation
    # 2. The assigned expert
    # 3. An expert viewing a waiting conversation (to decide whether to claim)
    is_initiator = conversation && conversation.initiator_id == current_user.id
    is_assigned_expert = conversation && conversation.assigned_expert_id == current_user.id
    is_expert_viewing_waiting = conversation && conversation.status == 'waiting' && ExpertProfile.exists?(user_id: current_user.id)
    
    unless is_initiator || is_assigned_expert || is_expert_viewing_waiting
      return render json: { error: 'Not authorized to view messages' }, status: :forbidden
    end

    messages = conversation.messages.order(created_at: :asc)
    render json: messages
  end

  # POST /conversations/:conversation_id/messages  
  def create

    conversation_id = params[:conversation_id] || params[:conversationId]
    conversation = Conversation.find_by(id: conversation_id)

    unless conversation
      return render json: { error: 'Conversation not found' }, status: :not_found
    end

    unless conversation.initiator_id == current_user.id || conversation.assigned_expert_id == current_user.id
      return render json: { error: 'Not authorized to send messages' }, status: :forbidden
    end

    role = current_user.id == conversation.initiator_id ? 'initiator' : 'expert'

    message = conversation.messages.new(
      sender_id: current_user.id,
      sender_role: role,
      content: params[:content]
    )

    if message.save
      conversation.update!(last_message_at: Time.current)
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /messages/:id/read
  def read
    message = Message.find_by(id: params[:id])
    return render json: { error: 'Message not found' }, status: :not_found unless message

    conversation = message.conversation
    if message.sender_id == current_user.id
      return render json: { error: 'Cannot mark your own message as read' }, status: :forbidden
    end

    message.update!(is_read: true)
    render json: { message: 'Message marked as read', id: message.id, is_read: true }
  end
end