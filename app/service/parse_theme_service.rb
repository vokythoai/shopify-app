class ParseThemeService
  class << self
    def add_discount html_content
      discount_html = "<div class='saso-volumes'>
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
                              <tr>
                                <td>2+</td>
                                <td><span class='saso-price'>10% Off</span><!-- <span class='saso-price'><span class=money>$11.69</span></span> --></td>
                                  <!-- <td><a href='#' class='saso-add-to-cart' data-quantity='2'>Add to Cart</a></td> -->
                              </tr>
                              <tr>
                                <td>3+</td>
                                <td><span class='saso-price'>15% Off</span><!-- <span class='saso-price'><span class=money>$11.04</span></span> --></td>
                                <!-- <td><a href='#' class='saso-add-to-cart' data-quantity='3'>Add to Cart</a></td> -->
                              </tr>
                              <tr>
                                <td>4+</td>
                                <td><span class='saso-price'>20% Off</span><!-- <span class='saso-price'><span class=money>$10.39</span></span> --></td>
                                <!-- <td><a href='#' class='saso-add-to-cart' data-quantity='4'>Add to Cart</a></td> -->
                              </tr>
                            </tbody>
                          </table>
                        </div>
                      </div>"
      unless (html_content =~ /div class='saso-volumes'/).present?
        insert_point = html_content =~ /<div class="product-form__item product-form__item--submit">/
        insert_point += ("<div class='product-form__item product-form__item--submit'>".size + 1)
        html_content.insert(insert_point, discount_html)
      end
      return html_content
      # html_content.gsub(discount_html, "")
    end
  end
end
