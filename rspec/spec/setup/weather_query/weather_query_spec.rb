
require 'spec_helper'
require 'setup/weather_query/weather_query'

describe Setup::WeatherQuery do
  subject(:weather_query) { described_class }

  describe 'caching' do
      let(:json_response) do
        '{"weather": {"description": "Sky is clear"}}'
      end

      before do
        expect(weather_query).to receive(:http).once.and_return(json_response)
      end

      after do
        weather_query.clear!
      end

      it "stores results in local cache" do
        weather_query.forecast('Malibu,US')

        actual = weather_query.send(:cache)
        expect(actual.keys).to eq(['Malibu,US'])
        expect(actual['Malibu,US']).to be_a(Hash)
      end

      it "uses cached result in subsequent queries" do
        weather_query.forecast('Malibu,US')
        weather_query.forecast('Malibu,US')
        weather_query.forecast('Malibu,US')
      end

      context "skip cache" do
        before do
          expect(weather_query).to receive(:http).with('Beijing,CN').and_return(json_response)
          expect(weather_query).to receive(:http).with('Delhi,IN').and_return(json_response)
        end

        it "hits API when false passed for use_cache" do
          weather_query.forecast('Malibu,US')
          weather_query.forecast('Beijing,CN', false)
          weather_query.forecast('Delhi,IN', false)

          actual = weather_query.send(:cache).keys
          expect(actual).to eq(['Malibu,US'])
        end
      end
  end

  describe 'query history' do
    before do
      weather_query.clear!

      expect(weather_query.history).to eq([])
      allow(weather_query).to receive(:http).and_return('{}')
    end

    after do
      weather_query.clear!
    end

    it "stores every place requested" do
      places = %w(
        Malibu,US
        Beijing,CN
        Delhi,IN
        Malibu,US
        Malibu,US
        Beijing,CN
      )

      places.each {|s| weather_query.forecast(s) }

      expect(weather_query.history).to eq(places)
    end

    it "does not allow history to be modified" do
      expect {
        weather_query.history = ['Malibu,CN']
      }.to raise_error(NoMethodError)

      expect(weather_query.history).to eq([])
    end
  end

  describe 'number of API requests' do
    before do
      weather_query.clear!

      expect(weather_query.history).to eq([])
      allow(weather_query).to receive(:http).and_return('{}')
    end

    after do
      weather_query.clear!
    end

    it "stores every place requested" do
      places = %w(
        Malibu,US
        Beijing,CN
        Delhi,IN
        Malibu,US
        Malibu,US
        Beijing,CN
      )

      places.each {|s| weather_query.forecast(s) }

      expect(weather_query.api_request_count).to eq(3)
    end

    it "does not allow history to be modified" do
      expect {
        weather_query.api_request_count = 100
      }.to raise_error(NoMethodError)

      expect {
        weather_query.api_request_count += 10
      }.to raise_error(NoMethodError)

      expect(weather_query.api_request_count).to eq(0)
    end
  end

  describe '.forecast' do
    context 'network errors' do
      let(:custom_error) { weather_query::NetworkError }

      before do
        expect(Net::HTTP).to receive(:get).and_raise(error_to_raise)
      end

      context 'timeouts' do
        let(:error_to_raise) { Timeout::Error }

        it "raises a NetworkError instead of Timeout::Error" do
          expect{
            weather_query.forecast('Antarctica')
          }.to raise_error(custom_error, "Request timed out")
        end
      end

      context 'invalid URI' do
        let(:error_to_raise) { URI::InvalidURIError }

        it "raises a NetworkError instead of URI::InvalidURIError" do
          expect{
            weather_query.forecast('Antarctica')
          }.to raise_error(custom_error, "Bad place name: Antarctica")
        end
      end

      context 'socket errors' do
        let(:error_to_raise) { SocketError }

        it "raises a NetworkError instead of SocketError" do
          expect{
            weather_query.forecast('Antarctica')
          }.to raise_error(custom_error, /Could not reach http:\/\//)
        end
      end
    end

    context 'parse errors' do
      let(:xml_response) do
        %q(
          <?xml version="1.0" encoding="utf-8"?>
          <current>
            <weather number="800" value="Sky is Clear" icon="01n"/>
          </current>
        )
      end

      it "raises a NetworkError if response is not JSON" do
        expect(weather_query).to receive(:http)
          .with('Antarctica')
          .and_return(xml_response)

        expect{
          weather_query.forecast('Antarctica')
        }.to raise_error(
          weather_query::NetworkError, "Bad response"
        )
      end
    end
  end
end
