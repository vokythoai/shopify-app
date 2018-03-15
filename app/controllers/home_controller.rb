class HomeController < ShopifyApp::AuthenticatedController

  def index
    shop = ShopifyAPI::Shop.current
    current_shop = Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
    @promotion = current_shop.promotions
  end
end
