require 'rails_helper'

RSpec.describe UploadRow, type: :model do
  describe 'associations' do
    it 'belongs to upload' do
      association = described_class.reflect_on_association(:upload)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    subject { build(:upload_row) }

    context 'when row_index is nil' do
      it 'is not valid' do
        subject.row_index = nil
        expect(subject).not_to be_valid
      end
    end

    context 'when row_index is not an integer' do
      it 'is not valid' do
        subject.row_index = 1.5
        expect(subject).not_to be_valid
      end
    end

    context 'when row_index is negative' do
      it 'is not valid' do
        subject.row_index = -1
        expect(subject).not_to be_valid
      end
    end

    context 'when values is nil' do
      it 'is not valid' do
        subject.values = nil
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload_row)).to be_valid
    end
  end
end
