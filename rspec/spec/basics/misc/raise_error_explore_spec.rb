
describe "raise_error" do
  # Disable false positive warning
  RSpec::Expectations.configuration.on_potential_false_positives = :nothing

  it "raises and error" do
    expect{ 1/0 }.to raise_error
    expect{ 1/0 }.to raise_error(ZeroDivisionError)
    expect{ 1/0 }.to raise_error(ZeroDivisionError, /divided/)
    expect{ 1/0 }.to raise_error(ZeroDivisionError, "divided by 0")

    expect{ 1/0 }.to raise_error do |e|
      expect(e.message).to eq("divided by 0")
    end
  end

  it "does not raise an error" do
    expect{ 1/1 }.to_not raise_error
  end
end
