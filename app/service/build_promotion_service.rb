class BuildPromotionService

  class << self
    def build_promotion params, shop
      promotion_param = params["promotion"]
      shop = Shop.where(shopify_domain: shop.attributes["domain"]).first
      shop_id = shop.id
      new_promotion = Promotion.new(
        promotion_type: Promotion::promotion_types[promotion_param["promotion_type"]],
        valid_date: promotion_param["valid_date"].to_date,
        end_date: promotion_param["end_date"].to_date,
        shop_id: shop_id
      )
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      if promotion_param["product"].present?
        product_param = promotion_param["product"]
        product_param.each do |product|
          if product.present?
            details = ShopifyAPI::Product.find(product.to_i).attributes
            product = Product.find_or_initialize_by(product_shopify_id: details["id"].to_i, name: details["title"])
            product.shop_id = shop_id
            product.save
            new_promotion.products << product
          end
        end
      end
      new_promotion.save
      if promotion_param[:promotion_details_attributes]
        promotion_param[:promotion_details_attributes].values.each do |attributes|
          promotion_details = attributes[:id].present? ? PromotionDetail.find(attributes[:id]) : PromotionDetail.new
          promotion_details.assign_attributes(
              qty: attributes[:qty].to_f,
              value: attributes[:value].to_f,
              discount_method: attributes[:discount_method].to_f,
              promotion_id: new_promotion.id
          )
          promotion_details.save
        end
      end
      return true
    end

    def update_promotion params, shop, promotion_id
      promotion = Promotion.find promotion_id
      promotion_param = params["promotion"]
      shop = Shop.where(shopify_domain: shop.attributes["domain"]).first
      shop_id = shop.id
      promotion.assign_attributes(
          promotion_type: Promotion::promotion_types[promotion_param["promotion_type"]],
          valid_date: promotion_param["valid_date"].to_date,
          end_date: promotion_param["end_date"].to_date
      )

      if promotion_param[:promotion_details_attributes]
        promotion.promotion_details.destroy_all
        promotion_param[:promotion_details_attributes].values.each do |attributes|
          promotion_details = PromotionDetail.new
          promotion_details.assign_attributes(
              qty: attributes[:qty].to_f,
              value: attributes[:value].to_f,
              discount_method: attributes[:discount_method].to_f,
              promotion_id: promotion_id
          )
          promotion_details.save
        end
      end

      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      if promotion_param["product"].present?
        product_ids = []
        product_param = promotion_param["product"]
        product_param.each do |product|
          if product.present?
            details = ShopifyAPI::Product.find(product.to_i).attributes
            product = Product.find_or_initialize_by(product_shopify_id: details["id"].to_i, name: details["title"])
            product.shop_id = shop_id
            product.save
            product_ids << product.id
          end
        end
        promotion.product_ids = product_ids.uniq
      end
      promotion.running!
      return true
    end
  end
end