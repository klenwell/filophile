class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to "/auth/google_oauth2" unless current_user
  end

  def record_not_found
    render plain: "404 Not Found", status: :not_found
  end
end
