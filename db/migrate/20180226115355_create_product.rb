class CreateProduct < ActiveRecord::Migration[5.1]
  def change
    create_table :products  do |t|
      t.string :product_name
      t.string :product_shopify_id
      t.integer :shop_id
      t.integer :promotion_id
      t.timestamps
    end
  end
end
