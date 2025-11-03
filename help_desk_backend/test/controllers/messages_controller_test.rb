require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @questioner = User.create!(username: "questioner", password: "password123")
    @expert = User.create!(username: "expert", password: "password123")
    @other_user = User.create!(username: "other_user", password: "password123")
    
    # Create expert profiles
    ExpertProfile.create!(user_id: @expert.id)
    
    @questioner_token = JwtService.encode(@questioner)
    @expert_token = JwtService.encode(@expert)
    @other_token = JwtService.encode(@other_user)
    
    # Create a waiting conversation
    @waiting_conversation = Conversation.create!(
      title: "Test Question", 
      initiator_id: @questioner.id, 
      status: "waiting"
    )
    
    # Create a message in the waiting conversation
    @waiting_message = Message.create!(
      conversation_id: @waiting_conversation.id,
      sender_id: @questioner.id,
      sender_role: "initiator",
      content: "This is a test question"
    )
    
    # Create an active conversation assigned to expert
    @active_conversation = Conversation.create!(
      title: "Active Question",
      initiator_id: @questioner.id,
      assigned_expert_id: @expert.id,
      status: "active"
    )
    
    @active_message = Message.create!(
      conversation_id: @active_conversation.id,
      sender_id: @questioner.id,
      sender_role: "initiator",
      content: "Active conversation message"
    )
  end

  test "initiator can view messages in their conversation" do
    get "/conversations/#{@waiting_conversation.id}/messages", 
        headers: { "Authorization" => "Bearer #{@questioner_token}" }
    assert_response :ok
    messages = JSON.parse(response.body)
    assert_equal 1, messages.length
    assert_equal "This is a test question", messages[0]["content"]
  end

  test "assigned expert can view messages in assigned conversation" do
    get "/conversations/#{@active_conversation.id}/messages",
        headers: { "Authorization" => "Bearer #{@expert_token}" }
    assert_response :ok
    messages = JSON.parse(response.body)
    assert_equal 1, messages.length
  end

  test "expert can view messages in waiting conversation without claiming" do
    get "/conversations/#{@waiting_conversation.id}/messages",
        headers: { "Authorization" => "Bearer #{@expert_token}" }
    assert_response :ok
    messages = JSON.parse(response.body)
    assert_equal 1, messages.length
    assert_equal "This is a test question", messages[0]["content"]
  end

  test "non-expert user cannot view messages in waiting conversation they don't own" do
    get "/conversations/#{@waiting_conversation.id}/messages",
        headers: { "Authorization" => "Bearer #{@other_token}" }
    assert_response :forbidden
    error = JSON.parse(response.body)
    assert_equal "Not authorized to view messages", error["error"]
  end

  test "user cannot view messages in conversation they are not part of" do
    get "/conversations/#{@active_conversation.id}/messages",
        headers: { "Authorization" => "Bearer #{@other_token}" }
    assert_response :forbidden
  end

  test "unauthenticated user cannot view messages" do
    get "/conversations/#{@waiting_conversation.id}/messages"
    assert_response :unauthorized
  end

  test "can create message in conversation as initiator" do
    post "/conversations/#{@waiting_conversation.id}/messages",
         params: { content: "New message" },
         headers: { "Authorization" => "Bearer #{@questioner_token}" }
    assert_response :created
    message = JSON.parse(response.body)
    assert_equal "New message", message["content"]
    assert_equal "initiator", message["senderRole"]
  end

  test "can create message in conversation as assigned expert" do
    post "/conversations/#{@active_conversation.id}/messages",
         params: { content: "Expert reply" },
         headers: { "Authorization" => "Bearer #{@expert_token}" }
    assert_response :created
    message = JSON.parse(response.body)
    assert_equal "Expert reply", message["content"]
    assert_equal "expert", message["senderRole"]
  end

  test "cannot create message in conversation user is not part of" do
    post "/conversations/#{@active_conversation.id}/messages",
         params: { content: "Unauthorized message" },
         headers: { "Authorization" => "Bearer #{@other_token}" }
    assert_response :forbidden
  end

  test "can mark other user's message as read" do
    put "/messages/#{@active_message.id}/read",
        headers: { "Authorization" => "Bearer #{@expert_token}" }
    assert_response :ok
    result = JSON.parse(response.body)
    assert_equal true, result["is_read"]
  end

  test "cannot mark own message as read" do
    put "/messages/#{@active_message.id}/read",
        headers: { "Authorization" => "Bearer #{@questioner_token}" }
    assert_response :forbidden
    error = JSON.parse(response.body)
    assert_equal "Cannot mark your own message as read", error["error"]
  end
end
