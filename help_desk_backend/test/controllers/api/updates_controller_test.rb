require "test_helper"

class Api::UpdatesControllerTest < ActionDispatch::IntegrationTest
  test "should get conversations" do
    get api_updates_conversations_url
    assert_response :success
  end

  test "should get messages" do
    get api_updates_messages_url
    assert_response :success
  end

  test "should get expert_queue" do
    get api_updates_expert_queue_url
    assert_response :success
  end
end
