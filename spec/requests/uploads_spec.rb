require 'rails_helper'

RSpec.describe "Uploads", type: :request do
  let(:user) { create(:user) }

  before do
    # In a real app, you'd likely have a login helper.
    # For this test, we're directly manipulating the session.
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "POST /uploads" do
    context "with valid parameters" do
      let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'valid.csv'), 'text/csv') }

      it "creates a new Upload and UploadRows" do
        expect {
          post uploads_path, params: { upload: { original_file: file } }
        }.to change(Upload, :count).by(1).and change(UploadRow, :count).by(3)

        expect(response).to redirect_to(upload_path(Upload.last))
        follow_redirect!
        expect(response.body).to include("File uploaded successfully.")

        upload = Upload.last
        expect(upload.filename).to eq("valid.csv")
        expect(upload.row_count).to eq(3)
        expect(upload.column_count).to eq(3)
        expect(upload.user).to eq(user)
      end
    end

    context "with invalid parameters" do
      it "rejects non-CSV files" do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'wrong_type.txt'), 'text/plain')
        post uploads_path, params: { upload: { original_file: file } }

        expect(response).to redirect_to(new_upload_path)
        follow_redirect!
        expect(response.body).to include("Invalid file type. Please upload a .csv file.")
        expect(Upload.count).to eq(0)
      end

      it "rejects empty files" do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'empty.csv'), 'text/csv')
        post uploads_path, params: { upload: { original_file: file } }

        expect(response).to redirect_to(new_upload_path)
        follow_redirect!
        expect(response.body).to include("File is empty.")
        expect(Upload.count).to eq(0)
      end

      it "rejects files with inconsistent columns" do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'malformed.csv'), 'text/csv')
        post uploads_path, params: { upload: { original_file: file } }

        expect(response).to redirect_to(new_upload_path)
        follow_redirect!
        expect(response.body).to include("All rows must have the same number of columns.")
        expect(Upload.count).to eq(0)
      end

      it "rejects duplicate files" do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'valid.csv'), 'text/csv')
        post uploads_path, params: { upload: { original_file: file } }
        expect(Upload.count).to eq(1)

        # Rewind file for second upload
        file.rewind
        post uploads_path, params: { upload: { original_file: file } }

        expect(response).to redirect_to(new_upload_path)
        follow_redirect!
        expect(response.body).to include("This file has already been uploaded.")
        expect(Upload.count).to eq(1)
      end

      it "handles no file being selected" do
        post uploads_path, params: { upload: { original_file: nil } }

        expect(response).to redirect_to(new_upload_path)
        follow_redirect!
        expect(response.body).to include("Please select a file to upload.")
        expect(Upload.count).to eq(0)
      end
    end

    context "when not authenticated" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "redirects to login page" do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'valid.csv'), 'text/csv')
        post uploads_path, params: { upload: { original_file: file } }

        expect(response).to redirect_to("/auth/google_oauth2")
      end
    end
  end
end
