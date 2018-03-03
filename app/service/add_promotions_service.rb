class AddPromotionsService

  class << self
    def add_promotion shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      section = ShopifyAPI::Asset.find('sections/product-template.liquid')
      cart = ShopifyAPI::Asset.find('sections/cart-template.liquid')
      new_snippet = ShopifyAPI::Asset.new({key: 'snippets/miskre-discount.liquid'})
      new_cart = ShopifyAPI::Asset.new({key: 'sections/cart-template-miskre-discount.liquid'})
      new_section = ShopifyAPI::Asset.new({key: 'sections/product-template-miskre-discount.liquid'})
      new_section.value = ParseThemeService.add_section(section.value, shop.promotions, shop)
      new_snippet.value = ParseThemeService.add_snippet(shop)
      new_cart.value = ParseThemeService.add_discount_cart(cart.value, shop.promotions, shop)
      new_section.save
      new_cart.save
      new_snippet.save
    end
  end
end