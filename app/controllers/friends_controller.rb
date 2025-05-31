class FriendsController < ApplicationController
  before_action :authorize_request

  def index
    render json: @current_user.friends
  end

  def create
    friend = @current_user.friends.create(friend_params)
    render json: friend, status: :created
  end

  private

  def friend_params
    params.require(:friend).permit(:name, :email)
  end

  def authorize_request
    header = request.headers['Authorization']
    token = header.split.last if header
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    @current_user = User.find(decoded['user_id'])
  rescue
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
