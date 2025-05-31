# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  before_action :authorize_request, only: [:me]

  def me
    render json: @current_user
  end
  def register
    user = User.new(user_params)
    if user.save
      token = encode_token(user.id)
      render json: { user: user, token: token }
    else
      render json: { error: 'Registration failed' }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token(user.id)
      render json: { user: user, token: token }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def encode_token(user_id)
    JWT.encode({ user_id: user_id }, Rails.application.secret_key_base)
  end

  def authorize_request
    header = request.headers['Authorization']
    token = header.split.last if header
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    @current_user = User.find(decoded['user_id'])
  rescue
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  # def authorize_request
  #   # 1) Try Bearer header first
  #   header = request.headers["Authorization"]
  #   token = header.split.last if header.present?
  #
  #   # 2) Fallback to the HTTP-only cookie if no header was sent
  #   if token.blank? && request.cookies["auth_token"].present?
  #     token = request.cookies["auth_token"]
  #   end
  #
  #   # 3) If still no token, reject
  #   return render json: { error: "Unauthorized" }, status: :unauthorized if token.blank?
  #
  #   # 4) Decode
  #   decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
  #   @current_user = User.find(decoded["user_id"])
  # rescue JWT::DecodeError, ActiveRecord::RecordNotFound
  #   render json: { error: "Unauthorized" }, status: :unauthorized
  # end

end
