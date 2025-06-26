require 'rails_helper'

RSpec.describe Upload, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'has many upload_rows' do
      association = described_class.reflect_on_association(:upload_rows)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated upload_rows' do
      association = described_class.reflect_on_association(:upload_rows)
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has one attached original_file' do
      upload = Upload.new
      expect(upload).to respond_to(:original_file)
    end
  end

  describe 'validations' do
    subject { build(:upload, user: user) }

    context 'when filename is nil' do
      it 'is not valid' do
        subject.filename = nil
        expect(subject).not_to be_valid
      end
    end

    context 'when content_hash is nil' do
      it 'is not valid' do
        subject.content_hash = nil
        expect(subject).not_to be_valid
      end
    end

    context 'when content_hash is not unique' do
      it 'is not valid' do
        create(:upload, user: user, content_hash: 'abc')
        subject.content_hash = 'abc'
        expect(subject).not_to be_valid
      end
    end

    context 'when row_count is nil' do
      it 'is not valid' do
        subject.row_count = nil
        expect(subject).not_to be_valid
      end
    end

    context 'when row_count is not an integer' do
      it 'is not valid' do
        subject.row_count = 1.5
        expect(subject).not_to be_valid
      end
    end

    context 'when row_count is negative' do
      it 'is not valid' do
        subject.row_count = -1
        expect(subject).not_to be_valid
      end
    end

    context 'when column_count is nil' do
      it 'is not valid' do
        subject.column_count = nil
        expect(subject).not_to be_valid
      end
    end

    context 'when column_count is not an integer' do
      it 'is not valid' do
        subject.column_count = 1.5
        expect(subject).not_to be_valid
      end
    end

    context 'when column_count is negative' do
      it 'is not valid' do
        subject.column_count = -1
        expect(subject).not_to be_valid
      end
    end

    context 'when uploaded_at is nil' do
      it 'is not valid' do
        subject.uploaded_at = nil
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:upload, user: user)).to be_valid
    end
  end
end
