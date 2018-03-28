class AddDomainToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :domain_url, :string
  end
end
