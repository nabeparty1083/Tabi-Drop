class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :spot, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body, null: false
      t.text :good_point
      t.text :bad_point
      t.integer :season, null: false
      t.integer :status, null: false, default: 0
      t.integer :purpose, null: false
      t.integer :companion_type, null: false
      t.string :image

      t.timestamps
    end

    add_index :reviews, %i[user_id spot_id], unique: true
  end
end
