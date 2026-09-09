class CreateSpots < ActiveRecord::Migration[8.1]
  def change
    create_table :spots do |t|
      t.string :name, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.string :address, null: false
      t.string :official_url
      t.integer :category, null: false

      t.timestamps
    end
    add_index :spots, [ :name, :address ], unique: true
  end
end
