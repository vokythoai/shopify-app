class PromotionsController < ShopifyApp::AuthenticatedController

  def index

  end

  def new
    @promotion = Promotion.new
  end

  def create
    shop = ShopifyAPI::Shop.current
    new_promotion = BuildPromotionService.build_promotion(params, shop)
    # if new_promotion.valid?
    #   new_promotion.save
    # end
    redirect_to root_path
  end

  def update
    shop = ShopifyAPI::Shop.current
    promotion_update = BuildPromotionService.update_promotion(params, shop, params[:id])
    redirect_to root_path
  end

  def edit
    @promotion = Promotion.find params[:id]
    @promotion.product = @promotion.products.collect{|p| p.product_shopify_id.to_i}
  end
end
