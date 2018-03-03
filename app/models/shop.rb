class Shop < ActiveRecord::Base
  include ShopifyApp::SessionStorage

  has_many :promotions
  has_many :shop_backups
  has_many :products
end
