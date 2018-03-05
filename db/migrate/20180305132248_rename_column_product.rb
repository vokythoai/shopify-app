class RenameColumnProduct < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :product_name, :name
  end
end
