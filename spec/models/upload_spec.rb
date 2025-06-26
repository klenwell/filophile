require 'rails_helper'

RSpec.describe Upload, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:upload_rows).dependent(:destroy) }

    it 'has one attached original_file' do
      upload = Upload.new
      expect(upload).to respond_to(:original_file)
    end
  end

  describe 'validations' do
    subject { create(:upload, user: user) }

    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:content_hash) }
    it { should validate_uniqueness_of(:content_hash) }
    it { should validate_presence_of(:row_count) }
    it { should validate_numericality_of(:row_count).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:column_count) }
    it { should validate_numericality_of(:column_count).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:uploaded_at) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload, user: user)).to be_valid
    end
  end
end
