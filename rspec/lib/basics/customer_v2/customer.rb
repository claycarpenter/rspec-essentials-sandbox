module CustomerV2
  class Customer

  end

  class Discount
    attr_reader :amount, :customer, :product

    def initialize(opts={})
      @customer = opts[:customer]
      @product = opts[:product]
      @amount = opts[:amount]
    end

    STORE = []
    class << self
      def create(opts={})
        STORE << self.new(opts)
      end

      def find(opts={})
        STORE.select do |discount|
          opts.all? do |k, v|
            discount.send(k) == v
          end
        end.first
      end
    end
  end
end
