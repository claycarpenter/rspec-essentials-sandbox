
require 'rspec'
require 'webmock/rspec'

RSpec.configure do |config|
  config.order = 'random'
  config.profile_examples = 1
  config.color = true

  # Disable network access
  WebMock.disable_net_connect!
end
