require "test_helper"

class Api::UpdatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = JwtService.encode({ user_id: @user.id })
  end

  # Conversations updates tests
  test "should get conversations updates with valid userId" do
    get "/api/conversations/updates", 
      params: { userId: @user.id },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_instance_of Array, json_response
  end

  test "should return error when userId is missing for conversations" do
    get "/api/conversations/updates",
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "userId parameter is required", json_response["error"]
  end

  test "should filter conversations by since timestamp" do
    get "/api/conversations/updates",
      params: { 
        userId: @user.id,
        since: 1.hour.ago.iso8601
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
  end

  test "should return error for invalid timestamp format in conversations" do
    get "/api/conversations/updates",
      params: { 
        userId: @user.id,
        since: "invalid-timestamp"
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid timestamp format"
  end

  # Messages updates tests
  test "should get messages updates with valid userId" do
    get "/api/messages/updates",
      params: { userId: @user.id },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_instance_of Array, json_response
  end

  test "should return error when userId is missing for messages" do
    get "/api/messages/updates",
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "userId parameter is required", json_response["error"]
  end

  test "should filter messages by since timestamp" do
    get "/api/messages/updates",
      params: { 
        userId: @user.id,
        since: 1.hour.ago.iso8601
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
  end

  test "should return error for invalid timestamp format in messages" do
    get "/api/messages/updates",
      params: { 
        userId: @user.id,
        since: "invalid-timestamp"
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid timestamp format"
  end

  # Expert queue updates tests
  test "should get expert queue updates with valid expertId" do
    get "/api/expert-queue/updates",
      params: { expertId: @user.id },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_includes json_response, "waitingConversations"
    assert_includes json_response, "assignedConversations"
  end

  test "should return error when expertId is missing" do
    get "/api/expert-queue/updates",
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "expertId parameter is required", json_response["error"]
  end

  test "should accept since timestamp but still return complete queue" do
    # Note: Expert queue returns complete state regardless of 'since' parameter
    # to ensure experts always see all waiting conversations
    get "/api/expert-queue/updates",
      params: { 
        expertId: @user.id,
        since: 1.hour.ago.iso8601
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_includes json_response, "waitingConversations"
    assert_includes json_response, "assignedConversations"
  end

  test "should return error for invalid timestamp format in expert queue" do
    get "/api/expert-queue/updates",
      params: { 
        expertId: @user.id,
        since: "invalid-timestamp"
      },
      headers: { "Authorization" => "Bearer #{@token}" }
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid timestamp format"
  end

  # Authentication tests
  test "should require authentication for conversations updates" do
    get "/api/conversations/updates", params: { userId: @user.id }
    assert_response :unauthorized
  end

  test "should require authentication for messages updates" do
    get "/api/messages/updates", params: { userId: @user.id }
    assert_response :unauthorized
  end

  test "should require authentication for expert queue updates" do
    get "/api/expert-queue/updates", params: { expertId: @user.id }
    assert_response :unauthorized
  end
end
