class MiscController < ApplicationController
  skip_before_action :authenticate_user!, :verify_authenticity_token, only: :maintenance

  def maintenance
    token = params.try(:[], :token)
    decoded_token = JWT.decode token, Rails.application.secrets.hmac_secret, true, { algorithm: 'HS512' }
    if decoded_token.first.try(:[], "authorized") == "true"
      `service nginx stop`
      `service mn_mode start`
      head :ok
    else
      head :unknown_error
    end
  rescue JWT::VerificationError
    head :forbidden
  rescue JWT::ExpiredSignature
    head :forbidden
  rescue
    head :internal_server_error
  end
end
