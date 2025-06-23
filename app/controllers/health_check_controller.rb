class HealthCheckController < ApplicationController
  def show
    render json: { status: "ok", timestamp: Time.current }
  end
end
