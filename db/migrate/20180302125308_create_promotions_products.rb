class CreatePromotionsProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products_promotions do |t|
      t.column :product_id, :integer
      t.column :promotion_id, :integer
    end
  end
end
