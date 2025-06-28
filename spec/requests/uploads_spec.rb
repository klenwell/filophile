require 'rails_helper'

RSpec.describe "Uploads", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    # Mock authentication
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /dashboard" do
    let!(:user_upload) { create(:upload, user: user, filename: "user_file.csv") }
    let!(:other_user_upload) { create(:upload, user: other_user, filename: "other_user_file.csv") }

    it "displays the current user's uploads" do
      get dashboard_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Uploads")
      expect(response.body).to include(user_upload.filename)
    end

    it "does not display uploads from other users" do
      get dashboard_path
      expect(response.body).not_to include(other_user_upload.filename)
    end
  end

  describe "GET /uploads/:id" do
    let!(:user_upload) { create(:upload, user: user, filename: "user_file.csv") }
    let!(:other_user_upload) { create(:upload, user: other_user, filename: "other_user_file.csv") }

    context "when viewing own upload" do
      it "is successful" do
        get upload_path(user_upload)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user_upload.filename)
        expect(response.body).to include("Data Preview")
      end
    end

    context "when viewing other user's upload" do
      it "returns a 404 not found response" do
        get upload_path(other_user_upload)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /uploads/:id/download" do
    let!(:user_upload) { create(:upload, user: user, filename: "user_file.csv") }
    let!(:other_user_upload) { create(:upload, user: other_user, filename: "other_user_file.csv") }
    let(:file_content) { "header1,header2\nvalue1,value2\n" }

    before do
      user_upload.original_file.attach(io: StringIO.new(file_content), filename: 'user_file.csv', content_type: 'text/csv')
    end

    context "when downloading own upload" do
      it "sends the file" do
        get download_upload_path(user_upload)
        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Disposition"]).to include("attachment; filename=\"user_file.csv\"")
        expect(response.body).to eq(file_content)
      end
    end

    context "when downloading other user's upload" do
      it "returns a 404 not found response" do
        get download_upload_path(other_user_upload)
        expect(response).to have_http_status(:not_found)
      end
    end
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
