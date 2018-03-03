class HomeController < ShopifyApp::AuthenticatedController
  def index
    # @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    shop = ShopifyAPI::Shop.current
    current_shop = Shop.where(shopify_domain: shop.attributes["domain"]).first
    @promotion = current_shop.promotions
    AddPromotionsService.add_promotion(current_shop)
  end
end
