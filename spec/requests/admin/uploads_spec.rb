require 'rails_helper'

RSpec.describe "Admin::Uploads", type: :request do
  let(:admin_user) { create(:user, email: 'klenwell@gmail.com', uid: '123456') }
  let(:regular_user) { create(:user, uid: '654321') }
  let!(:upload) { create(:upload, user: regular_user) }

  describe "GET /admin/uploads" do
    context "when logged in as admin" do
      before do
        sign_in(admin_user)
        get admin_uploads_path
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays the upload" do
        expect(response.body).to include(upload.filename)
      end
    end

    context "when logged in as a regular user" do
      before do
        sign_in(regular_user)
        get admin_uploads_path
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged in" do
      it "redirects to the login page" do
        get admin_uploads_path
        expect(response).to redirect_to("/auth/google_oauth2")
      end
    end
  end

  describe "GET /admin/uploads/:id" do
    context "when logged in as admin" do
      before do
        sign_in(admin_user)
        get admin_upload_path(upload)
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays the upload details" do
        expect(response.body).to include(upload.filename)
      end
    end

    context "when logged in as a regular user" do
      before do
        sign_in(regular_user)
        get admin_upload_path(upload)
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
