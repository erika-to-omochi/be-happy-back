class JwtService
  SECRET_KEY = ENV['DEVISE_JWT_SECRET_KEY']
  Rails.logger.info "JWT SECRET_KEY: #{SECRET_KEY}"


  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)  # 署名に使うキー
  end

  def self.decode(token)
    begin
      body = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
      Rails.logger.info "Decoded Token: #{body.inspect}"
      HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature
      Rails.logger.error "JWT Decode Error: Token has expired"
      nil
    rescue JWT::VerificationError
      Rails.logger.error "JWT Decode Error: Signature verification failed"
      nil
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      nil
    end
  end
end
