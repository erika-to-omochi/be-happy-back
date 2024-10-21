class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable,
        :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :email, presence: true, uniqueness: true

  # JWTトークンにデバイスIDを含める
  def jwt_payload
    {
      'user_id' => self.id,
      'device_id' => self.current_device_id   # 現在のデバイスIDを追加
    }
  end

  # JWT発行時にトークン情報を保存
  def on_jwt_dispatch(token, payload)
    TokenLog.create(user_id: self.id, token: token, issued_at: Time.now)
  end
end