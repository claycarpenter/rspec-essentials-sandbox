
require 'customer_v2/customer'
require 'pry'

class HaveDiscountOf
  def initialize(expected_discount)
    @expected = expected_discount
  end

  def matches?(customer)
    @actual = Discount.find(product: @product, customer: customer)
    @amt    = @actual && @actual.amount
    @amt == @expected
  end

  def for(product)
    @product = product
    self
  end

  def failure_message
    if @actual
      "Expected #{@product} discount of #{@expected}, got #{@amt}"
    else
      "#{@customer} has no discount for #{@product}"
    end
  end

  def failure_message_when_negated
    "Expected #{@actual} not to equal #{@expected}"
  end
end

describe "product discout" do
  def have_discount_of(discount)
    HaveDiscountOf.new(discount)
  end

  let(:product) { 'foo123' }
  let(:amount) { 0.1 }
  subject(:customer) { Customer.new }

  before do
    Discount.create(
      product: product,
      customer: customer,
      amount: amount
    )
  end

  it "detects when a customer has a discount" do
    expect(customer).to have_discount_of(amount).for(product)
  end

  it "detects when a customer does not have a discount" do
    expect(customer).not_to have_discount_of(amount).for('noFoo')
  end
end