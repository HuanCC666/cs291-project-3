class ConversationsController < ApplicationController
  before_action :authenticate_jwt!

  # GET /conversations
  def index
  end

  # GET /conversations/:id
  def show
  end

  # POST /conversations
  def create
  end
end
