class ExpertController < ApplicationController
  before_action :authenticate_jwt!

  # GET /expert/queue
  def queue
    waiting = Conversation.where(status: 'waiting')
    active  = Conversation.where(assigned_expert_id: current_user&.id, status: 'active')

    render json: {
      waitingConversations: waiting.as_json(only: [:id, :title, :status, :created_at]),
      assignedConversations: active.as_json(only: [:id, :title, :status, :created_at])
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
      render json: {
        message: 'Conversation claimed successfully',
        conversation: conversation.as_json(only: [:id, :title, :status, :assigned_expert_id])
      }
    end
  end

  # POST /expert/conversations/:conversation_id/unclaim
  def unclaim
    conversation = Conversation.find_by(id: params[:conversation_id], assigned_expert_id: current_user&.id)

    if conversation.nil?
      render json: { error: 'Conversation not found or not owned by you' }, status: :not_found
    else
      conversation.update!(assigned_expert_id: nil, status: 'waiting')
      render json: {
        message: 'Conversation unclaimed successfully',
        conversation: conversation.as_json(only: [:id, :title, :status])
      }
    end
  end

  # GET /expert/profile
  def profile
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    # Safe handling for optional fields
    bio = current_user.respond_to?(:bio) ? (current_user.bio || "") : ""

    links =
      if current_user.respond_to?(:knowledge_base_links)
        val = current_user.knowledge_base_links
        val.is_a?(Array) ? val : val.to_s.split(/\r?\n|,/).map(&:strip).reject(&:empty?)
      else
        []
      end

    render json: {
      id: current_user.id,
      username: current_user.username,
      bio: bio,
      knowledgeBaseLinks: links
    }
  end

  # PUT /expert/profile
  def update_profile
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

    links = params.dig(:user, :knowledgeBaseLinks) || []
    links = links.is_a?(Array) ? links : links.to_s.split(/\r?\n|,/).map(&:strip).reject(&:empty?)

    if current_user.update(bio: params.dig(:user, :bio), knowledge_base_links: links)
      render json: {
        message: 'Profile updated successfully',
        user: {
          id: current_user.id,
          username: current_user.username,
          bio: current_user.bio || "",
          knowledgeBaseLinks: current_user.knowledge_base_links || []
        }
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /expert/assignments/history
  def assignments_history
    conversations = Conversation.where(assigned_expert_id: current_user&.id, status: ['resolved', 'closed'])
    render json: conversations.as_json(only: [:id, :title, :status, :updated_at])
  end
end