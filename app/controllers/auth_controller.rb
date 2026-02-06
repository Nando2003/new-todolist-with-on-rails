class AuthController < ApplicationController
  def signup
    auth_service = AuthService.new(User)
    
    tokens = auth_service.signup(
      signup_params[:username],
      signup_params[:password]
    )
    
    if tokens[:errors].present?
      render json: { errors: tokens[:errors] }, status: :unprocessable_entity
    else
      render json: tokens, status: :created
    end
  end

  def login
    auth_service = AuthService.new(User)
    
    tokens = auth_service.login(
      login_params[:username],
      login_params[:password]
    )
    
    if tokens
      render json: tokens, status: :ok
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def refresh
    auth_service = AuthService.new(User)

    new_access_token = auth_service.refresh(
      params[:refresh_token]
    )
    if new_access_token
      render json: { access_token: new_access_token }, status: :ok
    else
      render json: { error: 'Invalid refresh token' }, status: :unauthorized
    end
  end

  private

  def signup_params
    params.permit(:username, :password)
  end

  private

  def login_params
    params.permit(:username, :password)
  end
end
