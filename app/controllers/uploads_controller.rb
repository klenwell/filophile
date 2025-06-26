require 'csv'
require 'digest'

class UploadsController < ApplicationController
  def index
    @uploads = current_user.uploads.order(uploaded_at: :desc)
  end

  def show
    @upload = find_upload
  end

  def new
    @upload = Upload.new
  end

  def create
    uploaded_io = params[:upload][:original_file]
    unless uploaded_io
      redirect_to new_upload_path, alert: 'Please select a file to upload.'
      return
    end

    process_csv_upload(uploaded_io)
  end

  private

  def find_upload
    current_user.uploads.find(params[:id])
  end

  def process_csv_upload(uploaded_io)
    if uploaded_io.content_type != 'text/csv' || !uploaded_io.original_filename.end_with?('.csv')
      redirect_to new_upload_path, alert: 'Invalid file type. Please upload a .csv file.'
      return
    end

    file_content = uploaded_io.read
    if file_content.blank?
      redirect_to new_upload_path, alert: 'File is empty.'
      return
    end

    content_hash = Digest::SHA256.hexdigest(file_content)
    if Upload.exists?(content_hash: content_hash, user_id: current_user.id)
      redirect_to new_upload_path, alert: 'This file has already been uploaded.'
      return
    end

    begin
      rows = CSV.parse(file_content, headers: false)
    rescue CSV::MalformedCSVError => e
      redirect_to new_upload_path, alert: "Error parsing CSV: #{e.message}"
      return
    end

    if rows.empty?
      redirect_to new_upload_path, alert: 'CSV file is empty.'
      return
    end

    first_row_column_count = rows.first.size
    unless rows.all? { |row| row.size == first_row_column_count }
      redirect_to new_upload_path, alert: 'All rows must have the same number of columns.'
      return
    end

    upload = Upload.new(
      user: current_user,
      filename: uploaded_io.original_filename,
      content_hash: content_hash,
      row_count: rows.size,
      column_count: first_row_column_count,
      uploaded_at: Time.current
    )
    upload.original_file.attach(io: StringIO.new(file_content), filename: uploaded_io.original_filename)

    if upload.save
      rows.each_with_index do |row_data, index|
        upload.upload_rows.create!(row_index: index, values: row_data)
      end
      redirect_to upload, notice: 'File uploaded successfully.'
    else
      redirect_to new_upload_path, alert: "Failed to save upload: #{upload.errors.full_messages.join(', ')}"
    end
  end
end
