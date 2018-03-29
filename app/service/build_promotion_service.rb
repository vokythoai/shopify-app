class BuildPromotionService
  extend ActionView::Helpers::NumberHelper
  class << self
    def build_promotion params, shop
      result = ""
      ActiveRecord::Base.transaction do
        promotion_param = params["promotion"]
        shop = Shop.where(shopify_domain: shop.attributes["domain"]).first || Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
        shop_id = shop.id
        new_promotion = Promotion.new(
          promotion_type: Promotion::promotion_types[promotion_param["promotion_type"]],
          valid_date: promotion_param["valid_date"].to_date,
          end_date: promotion_param["end_date"].to_date,
          shop_id: shop_id
        )
        session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
        ShopifyAPI::Base.activate_session(session)
        pages = (ShopifyAPI::Product.count.to_f / 50.to_f).ceil
        @products = []     # Collect all products in array
        (1..pages).each do |page|
          @products += ShopifyAPI::Product.all(params: { page: page, limit: 50 })
        end

        currency = ShopifyAPI::Shop.current.attributes["currency"]
        if promotion_param["product"].present? && promotion_param["all_product"] == "0"
          product_param = promotion_param["product"]
          product_param.each do |product|
            if product.present?
              details = @products.select{|a| a.attributes["id"] == product.to_i }.first.attributes
              product = Product.find_or_initialize_by(product_shopify_id: details["id"].to_i, name: details["title"])
              product.shop_id = shop_id
              product.save
              new_promotion.products << product
            end
          end
        elsif promotion_param["all_product"] == "1"
          @products.each do |product|
            product = Product.find_or_initialize_by(product_shopify_id: product.attributes["id"], name: product.attributes["title"])
            product.shop_id = shop_id
            product.save
            new_promotion.products << product
          end
        end
        @promotion_name = []
        if promotion_param[:promotion_details_attributes]
          promotion_param[:promotion_details_attributes].values.each do |attributes|
            promotion_details = attributes[:id].present? ? PromotionDetail.find(attributes[:id]) : PromotionDetail.new
            promotion_details.assign_attributes(
                qty: attributes[:qty].to_f,
                value: attributes[:value].to_f,
                discount_method: attributes[:discount_method].to_f
            )
            @promotion_name << (new_promotion.volume_amount? ? "#{promotion_details.qty.to_i}+ sale #{promotion_details.value}%" : "#{number_with_delimiter(promotion_details.qty.to_i, delimiter: ".", separator: ",")}#{currency} sale #{promotion_details.value}%")
            promotion_details.save
            new_promotion.promotion_details << promotion_details
          end
        end
        if new_promotion.valid?
          new_promotion.promotion_name = @promotion_name.join(" ")
          new_promotion.running!
        else
          result = new_promotion.errors.messages
          raise ActiveRecord::Rollback
        end
      end
      return result
    end

    def update_promotion params, shop, promotion_id
      result = ""
      currency = ShopifyAPI::Shop.current.attributes["currency"]
      ActiveRecord::Base.transaction do
        promotion = Promotion.find promotion_id
        promotion_param = params["promotion"]
        shop = Shop.where(shopify_domain: shop.attributes["domain"]).first || Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
        shop_id = shop.id
        promotion.assign_attributes(
            promotion_type: Promotion::promotion_types[promotion_param["promotion_type"]],
            valid_date: promotion_param["valid_date"].to_date,
            end_date: promotion_param["end_date"].to_date
        )
        @promotion_name = []
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
            @promotion_name << (promotion.volume_amount? ? "#{promotion_details.qty.to_i}+ sale #{promotion_details.value}%" : "#{ number_with_delimiter(promotion_details.qty.to_i, delimiter: ".", separator: ",")}#{currency} sale #{promotion_details.value}%")
            promotion_details.save
            promotion.promotion_details << promotion_details
          end
        end

        session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
        ShopifyAPI::Base.activate_session(session)
        pages = (ShopifyAPI::Product.count.to_f / 50.to_f).ceil
        @products = []     # Collect all products in array
        (1..pages).each do |page|
          @products += ShopifyAPI::Product.all(params: { page: page, limit: 50 })
        end

        if promotion_param["product"].present? && promotion_param["all_product"] == "0"
          product_ids = []
          product_param = promotion_param["product"]
          product_param.each do |product|
            if product.present?
              details = @products.select{|a| a.attributes["id"] == product.to_i }.first.attributes
              product = Product.find_or_initialize_by(product_shopify_id: details["id"].to_i, name: details["title"])
              product.shop_id = shop_id
              product.save
              product_ids << product.id
            end
          end
          promotion.product_ids = product_ids.uniq
        elsif promotion_param["all_product"] == "1"
          product_ids = []
          @products.each do |product|
            product = Product.find_or_initialize_by(product_shopify_id: product.attributes["id"], name: product.attributes["title"])
            product.shop_id = shop_id
            product.save
            product_ids << product.id
          end
          promotion.product_ids = product_ids.uniq
        end

        if promotion.valid?
          promotion.promotion_name = @promotion_name.join(" ")
          promotion.save
        else
          result = promotion.errors.messages
          raise ActiveRecord::Rollback
        end
      end
      return result
    end
  end
end