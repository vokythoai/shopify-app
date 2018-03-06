class PromotionsController < ShopifyApp::AuthenticatedController

  def index

  end

  def new
    @promotion = Promotion.new
  end

  def create
    shop = ShopifyAPI::Shop.current
    new_promotion = BuildPromotionService.build_promotion(params, shop)
    if new_promotion.blank?
      flash[:success] = "Create promotion successfully!"
      redirect_to root_path
    else
      flash[:notice] = new_promotion[:errors].join("\n")
      redirect_to root_path
    end
  end

  def update
    shop = ShopifyAPI::Shop.current
    promotion_update = BuildPromotionService.update_promotion(params, shop, params[:id])
    if promotion_update.blank?
      flash[:success] = "Create promotion successfully!"
      redirect_to root_path
    else
      flash[:notice] = promotion_update[:errors].join("\n")
      redirect_to root_path
    end
  end

  def destroy
    promotion = Promotion.find params[:id]
    if promotion.destroy
      flash[:success] = "Delete promotion successfully!"
      redirect_to root_path
    end
  end

  def edit
    @promotion = Promotion.find params[:id]
    @promotion.product = @promotion.products.collect{|p| p.product_shopify_id.to_i}
  end
end
