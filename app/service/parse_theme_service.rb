class ParseThemeService
  class << self
    def add_section html_content, promotions, shop
      discount_html = ""
      shop.products.each do |product|
      promotion = product.promotions.volume_amount.last
        shop = promotion.shop
        promotion_detail = eval(promotion.promotion_details)
        promotion_html = promotion_detail.inject("") do |html, promotion|
          html += "<tr>
                    <td>#{promotion[:qty].first.to_i}+</td>
                    <td><span class='saso-price'>#{promotion[:value].first.to_i}% Off</span>
                  </tr>"
        end
        product_liquid_array = promotion.products.pluck(:product_shopify_id).join("|")

        discount_html += "{% assign myProductId_#{promotion.id} = '#{product_liquid_array}'  %}
                         {% if myProductId_#{promotion.id} contains product.id %}
                            <div class='saso-volumes'>
                              <div class='saso-volume-discount-tiers'>
                                <h4>Buy more, Save more!</h4>
                                <table class='saso-table'>
                                  <thead>
                                    <tr>
                                      <th>Minimum Qty</th>
                                      <th>Discount</th>
                                      <!--<th>&nbsp;</th>-->
                                    </tr>
                                  </thead>
                                  <tbody>
                                    #{promotion_html}
                                  </tbody>
                                </table>
                              </div>
                            </div>
                          {% endif %}"
      end


      # html_content.gsub!(discount_html, "")
      unless (html_content =~ /div class='saso-volumes'/).present?
        insert_point = html_content =~ /<div class="product-form__item product-form__item--submit">/
        insert_point += ("<div class='product-form__item product-form__item--submit'>".size + 1)
        html_content.insert(insert_point, discount_html)
      end
      return html_content
    end

    def add_discount_cart html_content, promotions, shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      @promotion_html = ""
      shop.products.each do |product|
        promotion = product.promotions.volume_amount.last
        promotion_detail = eval(promotion.promotion_details)
        promotion.products.each do |product|
          @promotion_html += promotion_detail.inject("") do |html, detail|
            html += "{% if item.product_id == #{product.product_shopify_id} and item.quantity >= #{detail[:qty].first.to_i} %}
                  <span class='booster-cart-item-line-price' data-key='{{item.key}}' data-product='{{ item.product.id}}' data-item='{{ item.id}}' data-qty='{{item.quantity}}'>
                  <span class='original_price'>
                   {{ item.line_price | money }}
                  </span>
                  <span class='discounted_price'>
                   {{ 100 | minus: #{detail[:value].first.to_i} | times: item.line_price | divided_by: 100 | money }}
                   {% assign total = 100 | minus: #{detail[:value].first.to_i} | times: item.line_price | divided_by: 100 | plus: total  %}
                  </span>
                  {% else %}
                    <span class='booster-cart-item-line-price' data-key='{{item.key}}' data-product='{{ item.product.id}}' data-item='{{ item.id}}' data-qty='{{item.quantity}}'>{{ item.line_price | money }}</span>
                    {% assign total = item.line_price | plus: total  %}
                  {% endif %}"
          end
        end
      end

      unless (html_content =~ /<span class='booster-cart-item-line-price'/).nil?
        if @promotion_html
          html_content.prepend("{% assign total = 0 %}")
          html_content.gsub!('<span class="wh-cart-total"></span>', '<span class="wh-cart-total">{{ total| money }}</span>')
          html_content.gsub!("<span class='booster-cart-item-line-price' data-key='{{item.key}}'>{{ item.line_price | money }}</span>", @promotion_html)
        end
      end
      unless (html_content =~ /<input id="discount_input" type="hidden" name="discount" value="">/).present?
        insert_point_2 = html_content =~ /<form action="\/cart" method="post" novalidate class="cart">/
        if insert_point_2
          insert_point_2 += ('<form action="cart" method="post" novalidate class="cart">'.size + 1)
          html_content.insert(insert_point_2, '<input id="discount_input" type="hidden" name="discount" value="">')
        end
      end


      return html_content
    end

    def add_snippet shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      script_content = "\n{% if template contains 'product' %}\n\n\t<script type=\"text/javascript\">\n  \n\n      document.getElementById(\"MainContent\").innerHTML = null;\n      \n\n\n</script>\n{% section 'product-template-miskre-discount' %}\n{% endif %}\n\n{% if template contains 'cart' %}\n\n\t<script type=\"text/javascript\">\n      document.getElementById(\"MainContent\").innerHTML = \"\"\n    </script>\n\t{% section 'cart-template-miskre-discount' %}\n\t<script type=\"text/javascript\">\n      \n      function reqJquery(onload) {       \n        if(typeof jQuery === 'undefined' || (parseInt(jQuery.fn.jquery) === 1 && parseFloat(jQuery.fn.jquery.replace(/^1\\./,'')) < 10)){\n          var head = document.getElementsByTagName('head')[0];\n          var script = document.createElement('script');\n          var cookie = document.createElement('script');\n          script.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js';;\n          script.type = 'text/javascript';\n          script.onload = script.onreadystatechange = function() {\n            if (script.readyState) {\n              if (script.readyState === 'complete' || script.readyState === 'loaded') {\n                script.onreadystatechange = null;\n                onload(jQuery.noConflict(true));\n              }\n            }\n            else {\n              onload(jQuery.noConflict(true));\n            }\n          };\n          cookie.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min.js';;\n          cookie.type = 'text/javascript';\n          \n          head.appendChild(script);\n          head.appendChild(cookie);\n        }else {\n          onload(jQuery);\n        }\n      }\n\t\t\n  \n    reqJquery(function($){\n      var create_discount = false;\n      \tfunction addDiscount(code, button) {\n          \n          $(\"#discount_input\").val(code);\n          submitCart(button);\n       \t}\n    \t\n        function submitCart(button) {\n          create_discount = true;\n          $(button).delay(2000).click();\n         }\n          \n        var checkout_selectors = [\"input[name='checkout']\", \"button[name='checkout']\", \"[href$='checkout']\", \"input[name='goto_pp']\", \"button[name='goto_pp']\", \"input[name='goto_gc']\", \"button[name='goto_gc']\", \".additional-checkout-button\", \".google-wallet-button-holder\", \".amazon-payments-pay-button\"];\n        \n      \tcheckout_selectors.forEach(function(selector) {\n\n          var els = document.querySelectorAll(selector);\n\n          for (var i = 0; i < els.length; i++) {\n            var el = els[i];           \n            \n                \n            el.addEventListener(\"click\", function submitCart(ev) {\n              if (create_discount == false){\n              \tev.preventDefault();\n              }\n              \n              \n              var button = $(this)\n              try {\n                var self = $('#cart_form');\n                productArray = []\n                itemDetails = []\n                qty = []\n                $(\".booster-cart-item-line-price\").each(function() {\n                    productArray.push($(this).data(\"product\"));\n                  \titemDetails.push($(this).data(\"item\"));\n                  \tqty.push($(this).data(\"qty\"));\n                  \n                });\n                parameters = { original_price: $(\".wh-original-cart-total\").text(), discount_price: $(\".wh-cart-total\").text(), product_array: productArray, items_detail: itemDetails, qty: qty};\n                $.ajax({\n                  url: \"https://1aa5ef38.ap.ngrok.io/discount_cart\",\n                  type: \"POST\",\n                  data: parameters,\n                  dataType: \"json\",\n                  success: function(response){                    \n                     addDiscount(response.discount_code, button);\n                  },\n                  error: function(response){\n                    console.log(response);\n                  }\n                });\n                return true;\n              }\n              catch(err) {\n                 console.log(err);\n              }\n            }, false);\n          }\n\n            })\n               \n    })\n      \n\n      \n\n</script>\n{% endif %}\n\n"
      theme = ShopifyAPI::Asset.find('layout/theme.liquid')
      html_theme_value = theme.value
      unless (html_theme_value =~ /{% include 'miskre-discount' %}/).present?
        insert_point = html_theme_value =~ /{{ content_for_layout }}/
        if insert_point
          insert_point += ("{{ content_for_layout }}".size + 1)
          html_theme_value.insert(insert_point, "{% include 'miskre-discount' %}")
          theme.value = html_theme_value
          theme.save
        end
      end
      return script_content
    end
  end
end
