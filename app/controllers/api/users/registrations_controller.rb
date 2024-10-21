module Api
  module Users
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        user = User.new(user_params)

        if user.save
          token = JWT.encode({ user_id: user.id }, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
          render json: { message: 'Signed up successfully.', user: user, token: token }, status: :created
        else
          render json: { message: "User couldn't be created successfully.", errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
