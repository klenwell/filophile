class Admin::UploadsController < ApplicationController
  before_action :authorize_admin

  def index
    @pagy, @uploads = pagy(Upload.all.order(created_at: :desc))
  end

  def show
    @upload = Upload.find(params[:id])
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user.admin?
  end
end
