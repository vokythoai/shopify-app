ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = "2891ae73c20bbb2628bc54a60a22bcf3"
  config.secret = "7ed06b47b9a7e336cd2b43cc650d41b5"
  config.scope = "read_checkouts, write_checkouts, read_orders, write_orders, read_products, write_products, write_shipping, read_fulfillments, write_fulfillments, read_script_tags, write_script_tags, read_themes, write_themes, read_price_rules, write_price_rules"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
  config.webhooks = [
    {topic: 'app/uninstalled', address: 'http://1a3e9a91.ap.ngrok.io/webhooks/app_uninstalled', format: 'json'},
  ]
end
