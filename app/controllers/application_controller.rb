class ApplicationController < ActionController::API
  private

  def current_user_id
    request.env["current_user_id"]
  end

  def require_auth!
    return if current_user_id.present?
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
