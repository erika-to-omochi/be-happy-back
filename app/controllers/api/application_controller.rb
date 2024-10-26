module Api
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    respond_to :json
    skip_before_action :verify_authenticity_token, raise: false
    before_action :authenticate_user!
    rescue_from JWT::ExpiredSignature, with: :handle_expired_token

    def options
      head :ok
    end

    private

    def authenticate_user!
      token = request.headers['Authorization']&.split(' ')&.last
      Rails.logger.info "Token received: #{token.inspect}"
      return render json: { error: 'Unauthorized' }, status: :unauthorized unless token
      begin
        decoded_token = JwtService.decode(token)
        Rails.logger.info "Decoded Token: #{decoded_token.inspect}"
        if decoded_token['user_id']
          @current_user = User.find_by(id: decoded_token['user_id'])
        elsif decoded_token['guest_user_id']
          @current_user = GuestUser.find_by(id: decoded_token['guest_user_id'])
        end
        return render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError => e
        Rails.logger.error "JWT Decode Error: #{e.message}"
        render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
      rescue StandardError => e
        Rails.logger.error "Authentication Error: #{e.message}"
        render json: { error: "Internal server error: #{e.message}" }, status: :internal_server_error
      end
    end

    def current_user
      @current_user
    end

    def handle_expired_token
      render json: { error: 'Token has expired' }, status: :unauthorized
    end
  end
end
