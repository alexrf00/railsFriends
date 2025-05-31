class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      # … build payload …
      access_token  = JwtService.encode({ user_id: user.id }, expiry: 15.minutes.from_now.to_i)
      refresh_token = JwtService.encode({ user_id: user.id }, expiry: 14.days.from_now.to_i)

      # Set the HttpOnly, Secure cookie with the access token (or session)
      cookies.signed[:access_token] = {
        value:     access_token,
        httponly:  true,
        secure:    Rails.env.production?,
        same_site: :lax,
        expires:   15.minutes.from_now
      }

      # (Optionally also set a separate HttpOnly refresh cookie)
      cookies.signed[:refresh_token] = {
        value:     refresh_token,
        httponly:  true,
        secure:    Rails.env.production?,
        same_site: :lax,
        expires:   14.days.from_now
      }

      render json: { user: user.as_json(only: %i[id email name]) }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def destroy
    # This line removes the HttpOnly, signed cookie named :refresh_token
    cookies.delete(:refresh_token)
    render json: { message: "Logged out" }, status: :ok
  end
end
