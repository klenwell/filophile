require 'rails_helper'

RSpec.describe UploadRow, type: :model do
  describe 'associations' do
    it { should belong_to(:upload) }
  end

  describe 'validations' do
    it { should validate_presence_of(:row_index) }
    it { should validate_numericality_of(:row_index).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:values) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload_row)).to be_valid
    end
  end
end
