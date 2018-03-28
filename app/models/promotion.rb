class Promotion < ActiveRecord::Base
  attr_accessor :product, :all_product

  has_and_belongs_to_many :products
  belongs_to :shop
  has_many :promotion_details, dependent: :destroy
  accepts_nested_attributes_for :promotion_details

  default_scope { order("created_at ASC") }
  enum promotion_type: %w(volume_amount spend_amount)
  enum status: %w(running stopped)

  validate :validate_product, :validate_promotion_details

  def validate_product
    if products
      products.each do |product|
        Promotion.send(promotion_type).where.not(id: self.id).each do |promotion|
          if promotion.products.pluck(:product_shopify_id).include?(product.product_shopify_id)
            errors.add(:errors, "The products #{product.name} is in another promotion")
          end
        end
      end
    end
  end

  def validate_promotion_details
    unless self.promotion_details.present?
      errors.add(:errors, "Please select the promotion details!!")
    end
  end

  after_create do
    shop = ShopifyAPI::Shop.current
    current_shop = Shop.where(shopify_domain: shop.attributes["domain"]).first || Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
    AddPromotionsService.add_promotion(current_shop)
  end

  after_update do
    shop = ShopifyAPI::Shop.current
    current_shop = Shop.where(shopify_domain: shop.attributes["domain"]).first || Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
    AddPromotionsService.add_promotion(current_shop)
  end

  after_destroy do
    shop = ShopifyAPI::Shop.current
    current_shop = Shop.where(shopify_domain: shop.attributes["domain"]).first || Shop.where(shopify_domain: shop.attributes["myshopify_domain"]).first
    AddPromotionsService.add_promotion(current_shop)
  end
end
