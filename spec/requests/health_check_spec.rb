require "rails_helper"

RSpec.describe HealthCheckController, type: :request do
  describe "GET /api/health_check" do
    it "returns health status" do
      get "/api/health_check"
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["status"]).to eq("ok")
      expect(json_response["timestamp"]).to be_present
    end
  end
end
