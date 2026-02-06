class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    header = req.get_header("HTTP_AUTHORIZATION")
    token = header&.split&.last
    
    if header&.start_with?("Bearer ")
      token = header.slice(7..)
      claims = JwtSecurity.new.verify_access_token(token)
      env["current_user_id"] = claims["sub"] if claims
    end

    @app.call(env)
  end
end