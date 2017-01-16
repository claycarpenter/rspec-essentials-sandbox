
module CustomerV1
  class Customer
    attr_reader :discounts
    
    def initialize(opts)
      @discounts = opts[:discounts]
    end

    def has_discount_for?(product_code)
      @discounts.has_key?(product_code)
    end

    def discount_amount_for(product_code)
      @discounts[product_code] || 0
    end
  end
end
