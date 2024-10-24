module Api
  class GuestSessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:create]

    def create
      session_id = SecureRandom.hex(10)
      guest_user = GuestUser.find_or_create_by!(session_id: session_id)

      # トークン生成
      token = JWT.encode(
        { guest_user_id: guest_user.id, exp: 1.hour.from_now.to_i },
        ENV['DEVISE_JWT_SECRET_KEY'],
        'HS256'
      )
      render json: { token: token }, status: :created
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
