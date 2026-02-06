class UserService
  def initialize(user_model)
    @user_model = user_model
  end

  def me(user_id)
    @user_model.find_by(id: user_id)
  end
end