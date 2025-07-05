require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'associations' do
    it 'has many uploads' do
      association = described_class.reflect_on_association(:uploads)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated uploads' do
      association = described_class.reflect_on_association(:uploads)
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe '.from_omniauth' do
    context 'when the user already exists' do
      let!(:existing_user) { create(:user, provider: 'google_oauth2', uid: '123456', email: 'existing@example.com', name: 'Existing User') }
      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '123456',
          info: {
            email: 'existing@example.com',
            name: 'Existing User'
          }
        )
      end

      it 'returns the existing user without creating a new record' do
        expect {
          @result = described_class.from_omniauth(auth)
        }.not_to change(described_class, :count)

        expect(@result).to eq existing_user
      end
    end

    context 'when the user does not exist' do
      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '654321',
          info: {
            email: 'new@example.com',
            name: 'New User'
          }
        )
      end

      it 'creates a new user with attributes from the auth hash' do
        expect {
          @result = described_class.from_omniauth(auth)
        }.to change(described_class, :count).by(1)

        expect(@result.email).to eq 'new@example.com'
        expect(@result.name).to eq 'New User'
        expect(@result.uid).to eq '654321'
        expect(@result.provider).to eq 'google_oauth2'
      end
    end
  end

  describe '#admin?' do
    context 'when the email matches the admin email' do
      it 'returns true' do
        admin_user = build(:user, email: 'klenwell@gmail.com')
        expect(admin_user.admin?).to be true
      end
    end

    context 'when the email does not match the admin email' do
      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end
end
