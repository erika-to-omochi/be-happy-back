module Api
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    respond_to :json
    skip_before_action :verify_authenticity_token, raise: false

    def options
      head :ok
    end

    private

    def authenticate_user!
      token = request.headers['Authorization']&.split(' ')&.last
      Rails.logger.debug "Token received: #{token}"

      decoded_token = JwtService.decode(token)
      Rails.logger.debug "Decoded Token: #{decoded_token.inspect}"

      if decoded_token && decoded_token[:user_id]
        @current_user = User.find_by(id: decoded_token[:user_id])
        Rails.logger.debug "Current User: #{@current_user.inspect}"
      else
        Rails.logger.debug "Unauthorized access attempt"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
