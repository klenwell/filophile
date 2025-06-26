class CreateUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.string :filename
      t.string :content_hash
      t.integer :row_count
      t.integer :column_count
      t.datetime :uploaded_at

      t.timestamps
    end
    add_index :uploads, :content_hash, unique: true
  end
end
