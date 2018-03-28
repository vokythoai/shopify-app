class PromotionDetail < ActiveRecord::Base

  belongs_to :promotion, dependent: :destroy

end
