
require 'mocks/custom_mock/models'

# Custom mock support
class Object
  def self.mock(method_name, return_value)
    klass = self

    # Store existing method, if there is one, for restoration
    existing_method = if klass.method_defined?(method_name)
      klass.instance_method(method_name)
    else
      nil
    end

    klass.send(:define_method, method_name) do |*args|
      return_value
    end

    # Execute the passed block with the mock in effect
    yield if block_given?
  ensure
    # Restore klass to previous condition
    if existing_method
      klass.send(:define_method, method_name, existing_method)
    else
      klass.send(:remove_method, method_name)
    end
  end
end

RSpec.describe CustomMock::ShoppingCart do
  describe "\#total_price" do
    context "using our custom mock" do
      it "returns the sum of the prices of all products" do
        num_products = 22
        price = 100
        cart = CustomMock::ShoppingCart.new
        some_products = [CustomMock::Product.new] * num_products

        CustomMock::ShoppingCart.mock(:products, some_products) do
          CustomMock::Product.mock(:price, price) do
            expect(cart.total_price).to eq(num_products * price)
          end
        end
      end
    end

    context "using RSpec's allow_any_instance_of" do
      it "returns the sum of the prices of all products" do
        num_products = 22
        price = 100
        cart = CustomMock::ShoppingCart.new
        some_products = [CustomMock::Product.new] * num_products

        expect_any_instance_of(CustomMock::ShoppingCart).to receive(:products).and_return(some_products)

        allow_any_instance_of(CustomMock::Product).to receive(:price).and_return(price)

        expect(cart.total_price).to eq(num_products * price)
      end
    end
  end
end