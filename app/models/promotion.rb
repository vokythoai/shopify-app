class Promotion < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :shop
  default_scope { order("created_at ASC") }
  enum promotion_type: %w(volume_amount spend_amount)
  enum status: %w(running stopped)
end
