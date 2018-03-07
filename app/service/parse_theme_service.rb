class ParseThemeService
  class << self
    def add_section html_content, promotions, shop
      discount_html = ""
      promotions.volume_amount.each do |promotion|
        promotion_detail = promotion.promotion_details
        promotion_html = promotion_detail.inject("") do |html, promotion|
          html += "<tr>
                    <td>#{promotion.qty.to_i}+</td>
                    <td><span class='saso-price'>#{promotion.value.to_i}% Off</span>
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
      @condition_product_id = []
      @assign_product_ids = []
      @alert_discount_html = ""
      promotions.volume_amount.each_with_index do |promotion, index|
        @condition_product_id << promotion.products.pluck(:product_shopify_id)
        product_liquid_array = (promotion.products.pluck(:product_shopify_id) << '0').join("|")
        # promotion_detail = promotion.promotion_details
        qty = promotion.promotion_details.map{|a| [a.qty.to_i, a.value.to_i] }.sort {|x,y| y <=> x }
        alert_discount = promotion.promotion_details.map{|a| [a.qty.to_i, a.value.to_i] }.sort {|x,y| x <=> y }
        @assign_product_ids << "{% assign myProductId_#{promotion.id} = '#{product_liquid_array}'  %}"
        @content = ""
        qty.each_with_index do |detail, index_|
          @content += ((index.zero? && index_.zero?) ? "{% if myProductId_#{promotion.id} contains item.product_id and item.quantity >= #{detail[0].to_i} %}" : "{% elsif myProductId_#{promotion.id} contains item.product_id and item.quantity >= #{detail[0].to_i} %}")
          @content += "<span class='booster-cart-item-line-price' data-key='{{item.key}}' data-product='{{ item.product.id}}' data-item='{{ item.id}}' data-qty='{{item.quantity}}'>
                      <span class='original_price'>
                       {{ item.line_price | money }}
                      </span>
                      <span class='discounted_price'>
                       {{ 100 | minus: #{detail[1].to_i} | times: item.line_price | divided_by: 100 | money }}
                       {% assign total = 100 | minus: #{detail[1].to_i} | times: item.line_price | divided_by: 100 | plus: total  %}
                      </span>
                      </span>"
        end

        alert_discount.each_with_index do |detail, index_|
          @alert_discount_html += ((index.zero? && index_.zero?) ? "{% if myProductId_#{promotion.id} contains item.product_id and item.quantity < #{detail[0].to_i} %}" : "{% elsif myProductId_#{promotion.id} contains item.product_id and item.quantity < #{detail[0].to_i} %}")
          @alert_discount_html += "<span class='miskre-discount-note' data-id= {{item.id}}>Buy #{alert_discount[index_][0].to_i} to get #{alert_discount[index_][1].to_i}% off</span>"
        end
        @promotion_html +=  (@content.blank? ? "" : @content)
      end


      else_qty = "{% elsif true %}
                  <span class='booster-cart-item-line-price' data-key='{{item.key}}' data-product='{{ item.product.id}}' data-item='{{ item.id}}' data-qty='{{item.quantity}}'>{{ item.line_price | money }}</span>
                  {% assign total = item.line_price | plus: total  %}
                  {% endif %}"

      @alert_discount_html = @alert_discount_html.present? ? (@assign_product_ids.join("\n") + @alert_discount_html + "{% endif %}") : ""
      @promotion_html =  @assign_product_ids.join("\n") + @promotion_html + else_qty

      @spend_amount_html = ""
      @alert_spend_amount_html = ""
      promotions.spend_amount.each_with_index do |promotion, index|
        qty = promotion.promotion_details.map{|a| [a.qty.to_i, a.value.to_i] }.sort {|x,y| y <=> x }
        alert_spend_qty = promotion.promotion_details.map{|a| [a.qty.to_i, a.value.to_i] }.sort {|x,y| x <=> y }
        qty.each_with_index do |detail, index_|
          @spend_amount_html += ((index.zero? && index_.zero?) ? "{% if total >= #{detail[0].to_i*100} %}" : "{% elsif total >= #{detail[0].to_i*100} %}")
          @spend_amount_html += "<span class='wh-cart-total'>{{ 100 | minus: #{detail[1].to_i} | times: total | divided_by: 100 | money }}</span>"
          @spend_amount_html += "{% assign total_after_discount = 100 | minus: #{detail[1].to_i} | times: total | divided_by: 100  %}"
        end

        alert_spend_qty.each_with_index do |detail, index_|
          @alert_spend_amount_html += ((index.zero? && index_.zero?) ? "{% if total_after_discount < #{detail[0].to_i*100} %}" : "{% elsif total_after_discount < #{detail[0].to_i*100} %}")
          @alert_spend_amount_html += '<script type="text/javascript">' +
                                      'script = document.createElement("script");
                                        script.type = "text/javascript";
                                        script.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js";
                                        document.head.appendChild(script);
                                        script.onload = function() {' +
                                        'var html = "' + "<div id='miskre-notification-bar' style='display: block;'>Spend #{ActionController::Base.helpers.number_with_delimiter(detail[0].to_i)} to get #{detail[1].to_i}% off<div id='miskre-close-notification'>X</div></div>" + '";' +
                                        '$("main").prepend(html);' +
                                        '};' +
                                      '</script>'
        end
      end

      @alert_spend_amount_html = @alert_spend_amount_html.present? ? (@alert_spend_amount_html + "{% endif %}") : ""

      @spend_amount_html = @spend_amount_html.present? ? @spend_amount_html : '<span class="wh-cart-total">{{ total| money }}'

      else_spend_amount = "{% elsif true %}
                          <span class='wh-cart-total'>{{ total | money }}</span>
                          {% endif %}"
      total_qty = '<span class="cart__subtotal"><span class="wh-original-cart-total">{{ cart.total_price | money }}</span>' + (@spend_amount_html + else_spend_amount) + '</span><div class="additional-notes"><span class="wh-minimums-note"></span><span class="wh-extra-note "></span></div></span>' + @alert_spend_amount_html

      if @promotion_html
        html_content.prepend("{% assign total = 0 %}")
        # html_content.gsub!("<span class='booster-cart-item-line-price' data-key='{{item.key}}'>{{ item.line_price | money }}</span>", @promotion_html)
        html_content.gsub!("{{ item.line_price | money }}", @promotion_html)
        html_content.gsub!('<span class="cart__subtotal">{{ cart.total_price | money }}</span>', total_qty)
      end

      unless (html_content =~ /<input id="discount_input" type="hidden" name="discount" value="">/).present?
        insert_point_2 = html_content =~ /<form action="\/cart" method="post" novalidate class="cart">/
        if insert_point_2
          insert_point_2 += ('<form action="cart" method="post" novalidate class="cart">'.size + 1)
          html_content.insert(insert_point_2, '<input id="discount_input" type="hidden" name="discount" value="">')
        end
      end

      unless (html_content =~ /{{ item.product.title }}/).nil?
        insert_point_3 = html_content =~ /{{ item.product.title }}/
        if insert_point_3
          insert_point_3 += ("{{ item.product.title }}".size + 1)
          html_content.insert(insert_point_3, @alert_discount_html)
        end
      end

      return html_content
    end

    def add_snippet shop
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      script_content = "<style type=\"text/css\">\ndiv#miskre-notification-bar{\n  font-size: 110%;\n  background-color: #a1c65b;\n  padding: 12px;\n  color: #ffffff;\n  font-family: inherit;\n  z-index: 9999999999999;\n  display: block;\n  left: 0px;\n  width: 100%;\n  margin: 0px;\n  margin-bottom:20px;\n  text-align: center;\n  text-transform: none;\n}\n</style>\n\n{% if template contains 'product' %}\n\n\t<script type=\"text/javascript\">\n  \n\n      document.getElementById(\"MainContent\").innerHTML = null;\n      \n\n\n</script>\n{% section 'product-template-miskre-discount' %}\n{% endif %}\n\n{% if template contains 'cart' %}\n\n\t<script type=\"text/javascript\">\n      document.getElementById(\"MainContent\").innerHTML = \"\"\n    </script>\n\t{% section 'cart-template-miskre-discount' %}\n\t<script type=\"text/javascript\">\n      \n      function reqJquery(onload) {       \n        if(typeof jQuery === 'undefined' || (parseInt(jQuery.fn.jquery) === 1 && parseFloat(jQuery.fn.jquery.replace(/^1\\./,'')) < 10)){\n          var head = document.getElementsByTagName('head')[0];\n          var script = document.createElement('script');\n          var cookie = document.createElement('script');\n          script.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js';;\n          script.type = 'text/javascript';\n          script.onload = script.onreadystatechange = function() {\n            if (script.readyState) {\n              if (script.readyState === 'complete' || script.readyState === 'loaded') {\n                script.onreadystatechange = null;\n                onload(jQuery.noConflict(true));\n              }\n            }\n            else {\n              onload(jQuery.noConflict(true));\n            }\n          };\n          cookie.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min.js';;\n          cookie.type = 'text/javascript';\n          \n          head.appendChild(script);\n          head.appendChild(cookie);\n        }else {\n          onload(jQuery);\n        }\n      }\n\t\t\n  \n    reqJquery(function($){\n      $(\".wh-original-cart-total\").css({\"text-decoration\": \"line-through\", \"display\": \"block\"});\n        $(\".original_price\").css({\"text-decoration\": \"line-through\", \"display\": \"block\"});\n        $(\".discounted_price\").css({\"font-weight\": \"bold\"});\n      \t$(\".wh-cart-total\").css({\"font-weight\": \"bold\"});      \n      \t$(\".miskre-discount-note\").css({\"display\": \"block\", \"font-weight\": \"bold\", \"color\": \"#0078bd\", \"font-size\": \"100%\"});\n      \t$( document ).ready(function() {\n          $(\"main\").find(\"#miskre-close-notification\").css({\"float\": \"right\", \"font-weight\": \"bold\", \"height\": \"0\", \"overflow\": \"visible\", \"cursor\": \"pointer\", \"margin-right\": \"2em\"});\n   \t\t\t$(\"main\").find(\"#miskre-notification-bar\").css({\"font-size\": \"110%\", \"background-color\": \"#a1c65b\", \"padding\": \"12px\", \"color\": \"#ffffff\", \"font-family\": \"inherit\", \"z-index\": \"9999999999999\", \"display\": \"block\", \"left\": \"0px\", \"width\": \"100%\", \"margin\": \"0px\", \"margin-bottom\": \"20px\",\"text-align\": \"center\", \"text-transform\": \"none\"});\n        });\n      \t\n          \n      \tfunction addDiscount(code, button) {          \n          $(\"#discount_input\").val(code);          \n          submitCart(button);\n       \t}\n    \t\n        function submitCart(button) {\n          \n          $(button).delay(4000).click();\n         }\n          \n      \t     \n      \tvar create_discount = false;\n      \t\t\n        var checkout_selectors = [\"input[name='checkout']\", \"button[name='checkout']\", \"[href$='checkout']\", \"input[name='goto_pp']\", \"button[name='goto_pp']\", \"input[name='goto_gc']\", \"button[name='goto_gc']\", \".additional-checkout-button\", \".google-wallet-button-holder\", \".amazon-payments-pay-button\"];\n        \n      \tcheckout_selectors.forEach(function(selector) {\n\n          var els = document.querySelectorAll(selector);\n\n          for (var i = 0; i < els.length; i++) {\n            var el = els[i];           \n            \n            \n            el.addEventListener(\"click\", function submitCart(ev) {\n              if (create_discount == false){\n              \tev.preventDefault();\n              }\n              \n              \n              var button = $(this)\n              try {\n                var self = $('#cart_form');\n                productArray = []\n                itemDetails = []\n                qty = []\n                $(\".booster-cart-item-line-price\").each(function() {\n                    productArray.push($(this).data(\"product\"));\n                  \titemDetails.push($(this).data(\"item\"));\n                  \tqty.push($(this).data(\"qty\"));\n                  \n                });\n                parameters = { original_price: $(\".wh-original-cart-total\").text(), discount_price: $(\".wh-cart-total\").text(), product_array: productArray, items_detail: itemDetails, qty: qty};\n                if (create_discount == false){\n                  $.ajax({\n                    url: \"https://shopify-discount.herokuapp.com/discount_cart\",\n                    type: \"POST\",\n                    data: parameters,\n                    dataType: \"json\",\n                    success: function(response){ \n                       create_discount = true;\n                       addDiscount(response.discount_code, button);\n                    },\n                    error: function(response){\n                      console.log(response);\n                    }\n                  });\n                }\n                return true;\n              }\n              catch(err) {\n                 console.log(err);\n              }\n            }, false);\n          }\n\n            })\n               \n    })\n      \n\n      \n\n</script>\n{% endif %}\n\n"
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
