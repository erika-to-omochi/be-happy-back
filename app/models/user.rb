class User < ApplicationRecord
  before_create :set_jti
  has_many :memories, dependent: :destroy
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
  def set_jti
    self.jti = SecureRandom.uuid if jti.blank?
  end

  def on_jwt_dispatch(token, payload)
    TokenLog.create(user_id: self.id, token: token, issued_at: Time.now)
  end
end