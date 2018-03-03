class BuildPromotionService

  class << self
    def build_promotion params, shop
      promotion_param = params["promotion"]
      shop_id = Shop.where(shopify_domain: shop.attributes["domain"]).first.id
      promotion_details = promotion_param["promotion_details"][promotion_param["promotion_type"]].values.map do |promotion|
        {
            qty: promotion["qty"],
            value: promotion["value"],
            discount_method: promotion["discount_method"]
        }
      end

      new_promotion = Promotion.new(
        promotion_type: Promotion::promotion_types[promotion_param["promotion_type"]],
        promotion_details: promotion_details,
        valid_date: promotion_param["valid_date"].first.to_date,
        end_date: promotion_param["end_date"].first.to_date,
        shop_id: shop_id
      )

      product_param = JSON.parse(promotion_param["product"])
      product = Product.find_or_initialize_by(product_shopify_id: product_param.first, product_name: product_param.last)
      product.shop_id = shop_id
      new_promotion.products << product
      product.save
      new_promotion.running!
      return true
    end
  end
end