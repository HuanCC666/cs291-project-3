# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include ActionController::Cookies
  protect_from_forgery with: :null_session
  skip_forgery_protection

  private

  # Get token from Authorization header
  # Example: Authorization: Bearer <jwt>
  def bearer_token
    auth = request.headers['Authorization'].to_s
    auth.starts_with?('Bearer ') ? auth.split(' ', 2).last : nil
  end

  # Current user (from JWT)
  def current_user
    return @current_user if defined?(@current_user)

    token = bearer_token
    Rails.logger.info "=== AUTH DEBUG ==="
    Rails.logger.info "Header Authorization: #{request.headers['Authorization']}"
    Rails.logger.info "Bearer token: #{token ? '[PRESENT]' : '[MISSING]'}"

    begin
      payload = token.present? ? JwtService.decode(token) : nil
      Rails.logger.info "Decoded payload: #{payload.inspect}"
      @current_user = payload ? User.find_by(id: payload[:user_id]) : nil
      Rails.logger.info "User found: #{@current_user&.id || 'nil'}"
    rescue JWT::ExpiredSignature
      Rails.logger.error "JWT expired!"
      @current_user = nil
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT decode error: #{e.message}"
      @current_user = nil
    rescue StandardError => e
      Rails.logger.error "Unexpected auth error: #{e.class} - #{e.message}"
      @current_user = nil
    end

    @current_user
  end

  # Controllers requiring JWT should use this method
  def authenticate_jwt!
    begin
      user = current_user
      if user.nil?
        Rails.logger.warn "authenticate_jwt!: current_user is nil → Unauthorized"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      else
        Rails.logger.info "authenticate_jwt!: user=#{user.id}, username=#{user.username}"
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT decode error in authenticate_jwt!: #{e.message}"
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue StandardError => e
      Rails.logger.error "Auth error in authenticate_jwt!: #{e.class} - #{e.message}"
      render json: { error: 'Authentication failed' }, status: :unauthorized
    end
  end

  # Only for scenarios requiring session (cookie) authentication, e.g. /auth/refresh, /auth/logout, /auth/me
  def current_user_from_session
    uid = session[:user_id]
    uid ? User.find_by(id: uid) : nil
  end

  def require_session!
    unless current_user_from_session
      Rails.logger.warn "require_session!: No session found"
      render json: { error: 'No session found' }, status: :unauthorized
    end
  end
end