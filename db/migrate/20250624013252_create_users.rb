class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :uid
      t.string :provider, default: "google_oauth2"
      t.boolean :admin, default: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
