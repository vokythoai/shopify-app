class UninstallAppService

  class << self
    def uninstall_app shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      template = shop.shop_backups.last.layout_name
      backup_data = shop.shop_backups.last.backup_content
      asset = ShopifyAPI::Asset.find(template)
      asset.value.gsub!(backup_data, "")
      asset.save
    end
  end

end