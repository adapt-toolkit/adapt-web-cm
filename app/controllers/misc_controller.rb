class MiscController < ApplicationController
  def maintenance
    token = params.permit(:token).try(:[], :token)
    decoded_token = JWT.decode token, Rails.application.secrets.hmac_secret, true, { algorithm: 'HS512' }
    if decoded_token.first.try(:[], "data") == "authorized"
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
