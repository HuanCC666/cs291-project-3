class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include ActionController::Cookies

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
    payload = token.present? ? JwtService.decode(token) : nil
    @current_user = payload ? User.find_by(id: payload[:user_id]) : nil
  end

  # Controllers requiring JWT should use this method
  def authenticate_jwt!
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Only for scenarios requiring session (cookie) authentication, e.g. /auth/refresh, /auth/logout, /auth/me
  def current_user_from_session
    uid = session[:user_id]
    uid ? User.find_by(id: uid) : nil
  end

  def require_session!
    unless current_user_from_session
      render json: { error: 'No session found' }, status: :unauthorized
    end
  end
end
