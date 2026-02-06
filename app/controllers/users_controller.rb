class UsersController < ApplicationController
  before_action :require_auth!

  def me
    user = UserService.new(User).me(current_user_id)

    if user
      render json: {
        id: user.id,
        username: user.username,
        created_at: user.created_at,
        updated_at: user.updated_at
      }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end
end
