module OmniauthMacros
  def mock_auth_hash(user)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      'provider' => 'google_oauth2',
      'uid' => user.uid,
      'info' => {
        'name' => user.name,
        'email' => user.email
      }
    })
  end
end
