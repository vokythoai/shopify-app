class HomeController < ShopifyApp::AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = ShopifyAPI::Webhook.find(:all)
    asset = ShopifyAPI::Asset.find('sections/product-template.liquid')
    asset.value = ParseThemeService.add_discount(asset.value)
    asset.save
  end
end
