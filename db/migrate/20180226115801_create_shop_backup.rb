class CreateShopBackup < ActiveRecord::Migration[5.1]
  def change
    create_table :shop_backups do |t|
      t.integer :shop_id
      t.string :layout_name
      t.string :backup_content
      t.timestamps
    end
  end
end
