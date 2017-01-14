
require 'net/http'
require 'json'
require 'timeout'

module WeatherQuery
  NetworkError = Class.new(StandardError)

  class << self
    def forecast(place)
      response = http(place)

      JSON.parse(response)
    rescue JSON::ParserError
      raise NetworkError.new("Bad response")
    end

    private

    BASE_URI = 'http://api.openweathermap.org/data/2.5/weather?q='

    def http(place)
      uri = URI(BASE_URI + place)

      Net::HTTP.get(uri)
    rescue Timeout::Error
      raise NetworkError.new("Request timed out")
    rescue URI::InvalidURIError
      raise NetworkError.new("Bad place name: #{place}")
    rescue SocketError
      raise NetworkError.new("Could not reach #{uri.to_s}")
    end
  end
end
