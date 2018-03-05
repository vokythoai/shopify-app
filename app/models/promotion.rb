class Promotion < ActiveRecord::Base
  attr_accessor :product

  has_and_belongs_to_many :products
  belongs_to :shop
  has_many :promotion_details, dependent: :destroy
  accepts_nested_attributes_for :promotion_details

  default_scope { order("created_at ASC") }
  enum promotion_type: %w(volume_amount spend_amount)
  enum status: %w(running stopped)
end
