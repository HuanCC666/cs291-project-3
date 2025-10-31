class MessagesController < ApplicationController
  before_action :authenticate_jwt!

  # GET /conversations/:conversation_id/messages
  def index
  end

  # POST /conversations/:conversation_id/messages
  def create
  end

  # PUT /messages/:id/read
  def read
  end
end
