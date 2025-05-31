class TokensController < ApplicationController

  def refresh
    refresh_token = cookies.signed[:refresh_token]
    if refresh_token.blank?
      return render json: { error: "No refresh token" }, status: :unauthorized
    end

    decoded_payload = JwtService.decode(refresh_token)
    if decoded_payload.nil?
      cookies.delete(:refresh_token)
      return render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
    end

    user_id = decoded_payload["user_id"]
    user = User.find_by(id: user_id)
    if user.nil?
      cookies.delete(:refresh_token)
      return render json: { error: "User not found" }, status: :unauthorized
    end

    new_access_token  = JwtService.encode({ user_id: user.id }, expiry: JwtService::ACCESS_EXPIRY)
    new_refresh_token = JwtService.encode({ user_id: user.id }, expiry: JwtService::REFRESH_EXPIRY)

    cookies.signed[:refresh_token] = {
      value:     new_refresh_token,
      httponly:  true,
      secure:    Rails.env.production?,
      same_site: :strict,
      expires:   JwtService::REFRESH_EXPIRY.seconds.from_now
    }

    render json: { access_token: new_access_token }, status: :ok
  end
end
