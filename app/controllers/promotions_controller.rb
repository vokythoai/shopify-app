class PromotionsController < ShopifyApp::AuthenticatedController

  def index

  end

  def new

  end

  def create
    shop = ShopifyAPI::Shop.current
    new_promotion = BuildPromotionService.build_promotion(params, shop)
    # if new_promotion.valid?
    #   new_promotion.save
    # end
    redirect_to root_path
  end

  def discount_cart params
    binding.pry
  end

end
