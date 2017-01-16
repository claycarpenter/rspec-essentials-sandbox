
module CustomMock
  class ShoppingCart
    def total_price
      products.inject(0) do |sum, product|
        sum += product.price
      end
    end
  end

  class Product; end
end
