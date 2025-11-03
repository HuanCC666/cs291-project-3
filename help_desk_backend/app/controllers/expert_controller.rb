class ExpertController < ApplicationController
  before_action :require_session_or_jwt!

  # GET /expert/queue
  def queue
    waiting = Conversation.where(status: 'waiting')
    active  = Conversation.where(assigned_expert_id: current_user&.id, status: 'active')

    render json: {
      waitingConversations: waiting.as_json,
      assignedConversations: active.as_json
    }
  end

  # POST /expert/conversations/:conversation_id/claim
  def claim
    conversation = Conversation.find_by(id: params[:conversation_id])

    if conversation.nil?
      render json: { error: 'Conversation not found' }, status: :not_found
    elsif conversation.assigned_expert_id.present?
      render json: { error: 'Conversation already claimed' }, status: :unprocessable_entity
    else
      conversation.update!(assigned_expert_id: current_user&.id, status: 'active')
      render json: { success: true }
    end
  end

  # POST /expert/conversations/:conversation_id/unclaim
  def unclaim
    conversation = Conversation.find_by(id: params[:conversation_id], assigned_expert_id: current_user&.id)

    if conversation.nil?
      render json: { error: 'Conversation not found or not owned by you' }, status: :not_found
    else
      conversation.update!(assigned_expert_id: nil, status: 'waiting')
      render json: { success: true }
    end
  end

  # GET /expert/profile
  def profile
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    expert_profile = ExpertProfile.find_or_create_by(user_id: current_user.id)
    render json: expert_profile
  end

  # PUT /expert/profile
  def update_profile
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    expert_profile = ExpertProfile.find_or_create_by(user_id: current_user.id)
    
    links = params[:knowledgeBaseLinks] || []
    links = links.is_a?(Array) ? links : links.to_s.split(/\r?\n|,/).map(&:strip).reject(&:empty?)

    if expert_profile.update(bio: params[:bio], knowledge_base_links: links)
      render json: expert_profile
    else
      render json: { errors: expert_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /expert/assignments/history
  def assignments_history
    assignments = ExpertAssignment.where(expert_id: current_user&.id)
    render json: assignments
  end
end