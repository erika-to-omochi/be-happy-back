class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  skip_before_action :verify_authenticity_token, raise: false
  def options
    head :ok
  end
end
