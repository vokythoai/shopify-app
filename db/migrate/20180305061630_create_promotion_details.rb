class CreatePromotionDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :promotion_details do |t|
      t.integer :promotion_id
      t.string :content
      t.decimal :qty
      t.decimal :value
      t.string :discount_method
      t.timestamps
    end
  end
end
