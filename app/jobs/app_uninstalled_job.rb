class AppUninstalledJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
      template = shop.shop_backups.last.layout_name
      backup_data = shop.shop_backups.last.backup_content
      asset = ShopifyAPI::Asset.find(template)
      asset.value.gsub!(backup_data, "")
      asset.save
    end
  end
end
