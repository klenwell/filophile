class AddIndexToUploadRowsOnUploadIdAndRowIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :upload_rows, [:upload_id, :row_index]
  end
end
