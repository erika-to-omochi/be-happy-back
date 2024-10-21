module Api
  module Users
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        user = User.find_by(email: params[:user][:email])

        if user&.valid_password?(params[:user][:password])
          exp = 24.hours.from_now.to_i # トークンに有効期限を設定
          token = JWT.encode({ user_id: user.id, exp: exp }, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
          response.set_header('Authorization', "Bearer #{token}") # トークンをレスポンスのヘッダーにセット
          render json: { token: token, user: user }, status: :ok # レスポンスボディにユーザー情報とトークンを含めて返す
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def respond_to_on_destroy
        head :no_content
      end

      def destroy
        super
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
