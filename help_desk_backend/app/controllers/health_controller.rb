class HealthController < ApplicationController

  def index
    render json: {
      status: 'ok',
      rails_env: Rails.env,
      db_connected: db_connected?,
      timestamp: Time.current.iso8601
    }
  end

  private

  def db_connected?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end
end