class AuthController < ApplicationController
  # register/login don't need JWT; refresh/me/logout need session or JWT
  before_action :require_session_or_jwt!, only: [:refresh, :me, :logout]

  # POST /auth/register
  def register
    user = User.new(username: params[:username], password: params[:password])
    if user.save
      session[:user_id] = user.id  # Create session (set cookie)
      token = JwtService.encode(user)
      render json: {
        user: {
          id: user.id,
          username: user.username,
          created_at: user.created_at.iso8601,
          last_active_at: user.last_active_at&.iso8601
        },
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /auth/login
  def login
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.update_column(:last_active_at, Time.current)
      token = JwtService.encode(user)
      render json: {
        user: {
          id: user.id, username: user.username,
          created_at: user.created_at.iso8601,
          last_active_at: user.last_active_at&.iso8601
        },
        token: token
      }
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  # POST /auth/logout
  def logout
    reset_session
    render json: { message: 'Logged out successfully' }
  end

  # POST /auth/refresh
  def refresh
    user = @current_user
    token = JwtService.encode(user)
    render json: {
      user: {
        id: user.id, username: user.username,
        created_at: user.created_at.iso8601,
        last_active_at: user.last_active_at&.iso8601
      },
      token: token
    }
  end

  # GET /auth/me
  def me
    user = @current_user
    render json: {
      id: user.id, username: user.username,
      created_at: user.created_at.iso8601,
      last_active_at: user.last_active_at&.iso8601
    }
  end

  private

  # Allow either session-based or JWT-based authentication
  def require_session_or_jwt!
    # Try session first
    @current_user = current_user_from_session

    # Fallback to JWT if no session found
    unless @current_user
      token_user = current_user
      @current_user = token_user if token_user.present?
    end

    unless @current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end