require 'jwt'

class JwtSecurity
  JWT_SECRET = ENV['JWT_SECRET'] || 'your_secret_key_here'
  JWT_ALGORITHM = ENV['JWT_ALGORITHM'] || 'HS256'
  ACCESS_TOKEN_LIFETIME = ENV['ACCESS_TOKEN_LIFETIME'] || '15m'
  REFRESH_TOKEN_LIFETIME = ENV['REFRESH_TOKEN_LIFETIME'] || '7d'

  def generate_access_token(user_id)
    encode(base_claims("access", ParseDuration.parse(ACCESS_TOKEN_LIFETIME), user_id))
  end

  def generate_refresh_token(user_id)
    encode(base_claims("refresh", ParseDuration.parse(REFRESH_TOKEN_LIFETIME), user_id))
  end

  def refresh_access_token(refresh_token)
    claims = decode(refresh_token)
    return nil unless claims && claims["typ"] == "refresh"

    user_id = claims["sub"]
    return generate_access_token(user_id)
  end

  def verify_access_token(token)
    claims = decode(token)
    return nil unless claims && claims["typ"] == "access"
    claims
  end

  private
  
  def base_claims(token_type, ttl, user_id)
    now = Time.now.to_i
    {
      typ: token_type,
      sub: user_id,
      iat: now,
      exp: now + ttl
    }
  end

  private

  def encode(claims)
    JWT.encode(claims, JWT_SECRET, JWT_ALGORITHM)
  end

  private

  def decode(token)
    decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM })
    decoded_token[0]
  rescue JWT::DecodeError
    nil
  end
end