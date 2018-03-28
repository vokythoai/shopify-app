class Shop < ActiveRecord::Base
  include ShopifyApp::SessionStorage

  has_many :promotions
  has_many :shop_backups
  has_many :products

  after_commit do
    session = ShopifyAPI::Session.new(self.shopify_domain, self.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    domain = ShopifyAPI::Shop.current.attributes["domain"]
    self.domain_url = domain
  end
end
