class CreatePromotion < ActiveRecord::Migration[5.1]
  def change
    create_table :promotions do |t|
      t.integer :product_id
      t.integer :promotion_type
      t.string :promotion_details
      t.date :valid_date
      t.date :end_date
      t.timestamps
    end
  end
end
