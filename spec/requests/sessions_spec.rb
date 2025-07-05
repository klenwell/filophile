require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123545',
      info: {
        name: 'John Doe',
        email: 'john.doe@example.com'
      }
    })
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  describe "GET /auth/google_oauth2/callback" do
    it "creates a user and a session" do
      get '/auth/google_oauth2/callback'
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(User.last.id)
      expect(User.last.name).to eq('John Doe')
    end
  end

  describe "DELETE /logout" do
    before do
      get '/auth/google_oauth2/callback'
    end

    it "destroys the session" do
      delete '/logout'
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to be_nil
    end
  end
end
