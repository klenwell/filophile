class CreateUploadRows < ActiveRecord::Migration[7.1]
  def change
    create_table :upload_rows do |t|
      t.references :upload, null: false, foreign_key: true
      t.integer :row_index
      t.json :values

      t.timestamps
    end
  end
end
