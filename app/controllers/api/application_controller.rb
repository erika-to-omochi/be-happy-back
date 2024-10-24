module Api
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    respond_to :json
    skip_before_action :verify_authenticity_token, raise: false

    before_action :authenticate_user!

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
        # guest_user_id または user_id に応じて検索
        if decoded_token['user_id']
          @current_user = User.find_by(id: decoded_token['user_id'])
        elsif decoded_token['guest_user_id']
          @current_user = GuestUser.find_by(id: decoded_token['guest_user_id'])
        end
        return render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
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
  end
end
