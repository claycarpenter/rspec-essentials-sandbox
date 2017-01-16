require 'rspec'
require 'rspec/expectations'

require 'basics/customer_v1/customer'

RSpec::Matchers.define :be_discounted do |product, expected|
  match do |customer|
    @actual = customer.discount_amount_for(product)

    customer.discount_amount_for(product) == expected
  end

  failure_message do |actual|
    "expected #{product} discount of #{expected}, got #{actual}"
  end
end

class CustomerV1::HaveDiscountOf
  def initialize(expected)
    @expected = expected
  end

  def matches?(customer)
    @actual = customer.discount_amount_for(@product)

    @actual == @expected
  end

  def for(product)
    @product = product
    self
  end

  def failure_message
    "expected #{@product} discount of #{@expected}, got #{@actual}"
  end
end

describe "product discount" do
  def have_discount_of(discount)
    CustomerV1::HaveDiscountOf.new(discount)
  end

  let(:product) { 'foo123' }
  let(:discounts) { { product => 0.1 } }
  subject(:customer) { CustomerV1::Customer.new(discounts: discounts) }

  it "detects when customer has a discount" do
    expect(customer).to be_discounted(product, 0.1)
  end

  it "detects when customer has a discount (class matcher)" do
    expect(customer).to have_discount_of(0.1).for(product)
  end
end
