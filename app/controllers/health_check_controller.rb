class HealthCheckController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render json: { status: "ok", timestamp: Time.current }
  end
end
