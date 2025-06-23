class HealthCheckController < ActionController::API
  def show
    render json: { status: "ok", timestamp: Time.current }
  end
end
