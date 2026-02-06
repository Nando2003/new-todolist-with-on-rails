class AuthService
  def initialize(user_model)
    @user_model = user_model
    @jwt = JwtSecurity.new
  end

  def signup(username, password)
    hashed_password = BCrypt::Password.create(password)
    user = @user_model.create(username: username, password_digest: hashed_password)

    access_token = @jwt.generate_access_token(user.id)
    refresh_token = @jwt.generate_refresh_token(user.id)

    {
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def login(username, password)
    user = @user_model.find_by(username: username)
    return nil unless user && BCrypt::Password.new(user.password_digest) == password

    access_token = @jwt.generate_access_token(user.id)
    refresh_token = @jwt.generate_refresh_token(user.id)

    {
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def refresh(refresh_token)
    @jwt.refresh_access_token(refresh_token)
  end
end