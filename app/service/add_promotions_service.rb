class AddPromotionsService

  class << self
    def add_promotion shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)

      section = ShopifyAPI::Asset.find('sections/product-template.liquid')
      new_section = ShopifyAPI::Asset.new({key: 'sections/product-template-miskre-discount.liquid'})
      new_section.value = ParseThemeService.add_section(section.value, shop.promotions, shop)
      new_section.save

      cart = ShopifyAPI::Asset.find('sections/cart-template.liquid')
      new_cart = ShopifyAPI::Asset.new({key: 'sections/cart-template-miskre-discount.liquid'})
      new_cart.value = ParseThemeService.add_discount_cart(cart.value, shop.promotions, shop)
      new_cart.save

      new_snippet = ShopifyAPI::Asset.new({key: 'snippets/miskre-discount.liquid'})
      new_snippet.value = ParseThemeService.add_snippet(shop)
      new_snippet.save
    end

    def add_promotion_for_gadsack shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)

      product_template = ShopifyAPI::Asset.find('templates/product-template.liquid')
      product_template.value.gsub!("{% section 'product-template' %}", "{% section 'product-template-miskre-discount' %}")
      product_template.save

      section = ShopifyAPI::Asset.find('sections/product-template.liquid')
      new_section = ShopifyAPI::Asset.new({key: 'sections/product-template-miskre-discount.liquid'})
      new_section.value = GadsackParseThemeService.add_section(section.value, shop.promotions, shop)
      new_section.save

      cart = ShopifyAPI::Asset.find('templates/cart.liquid')
      new_cart = ShopifyAPI::Asset.new({key: 'sections/cart-template-miskre-discount.liquid'})
      new_cart.value = GadsackParseThemeService.add_discount_cart(cart.value, shop.promotions, shop)
      new_cart.save

      new_snippet = ShopifyAPI::Asset.new({key: 'snippets/miskre-discount.liquid'})
      new_snippet.value = GadsackParseThemeService.add_snippet(shop)
      new_snippet.save
    end
  end
end