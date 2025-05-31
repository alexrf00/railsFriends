# app/services/jwt_service.rb
require "jwt"

class JwtService
  ALGORITHM       = "HS256"
  ACCESS_EXPIRY   = 15.minutes.from_now.to_i
  REFRESH_EXPIRY  = 14.days.from_now.to_i

  # payload should be a hash, e.g. { user_id: 123 }
  # expiry should be an integer (Unix timestamp)
  def self.encode(payload, expiry:)
    payload_with_exp = payload.merge({ exp: expiry })
    JWT.encode(payload_with_exp, Rails.application.secret_key_base, ALGORITHM)
  end

  def self.decode(token)
    decoded_array = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: ALGORITHM })
    decoded_array.first   # returns a hash of the payload
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
