class CreatePromotion < ActiveRecord::Migration[5.1]
  def change
    create_table :promotions do |t|
      t.string :promotion_name
      t.integer :promotion_type
      t.string :promotion_details
      t.string :qty_option
      t.string :messages
      t.string :customer_option
      t.integer :status
      t.date :valid_date
      t.date :end_date
      t.timestamps
    end
  end
end
