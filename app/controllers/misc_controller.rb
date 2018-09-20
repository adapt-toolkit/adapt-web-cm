class MiscController < ApplicationController
  def token
    
  end
  def maintenance
    `service nginx stop`
    head :ok
  end
end
