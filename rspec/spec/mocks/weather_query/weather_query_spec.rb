
require 'mocks/weather_query/weather_query'

describe WeatherQuery do
  describe 'caching' do
      let(:json_response) do
        '{"weather": {"description": "Sky is clear"}}'
      end

      before do
        expect(WeatherQuery).to receive(:http).once.and_return(json_response)
      end

      after do
        WeatherQuery.instance_variable_set(:@cache, nil)
      end

      it "stores results in local cache" do
        WeatherQuery.forecast('Malibu,US')

        actual = WeatherQuery.send(:cache)
        expect(actual.keys).to eq(['Malibu,US'])
        expect(actual['Malibu,US']).to be_a(Hash)
      end

      it "uses cached result in subsequent queries" do
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
      end

      context "skip cache" do
        before do
          expect(WeatherQuery).to receive(:http).with('Beijing,CN').and_return(json_response)
          expect(WeatherQuery).to receive(:http).with('Delhi,IN').and_return(json_response)
        end

        it "hits API when false passed for use_cache" do
          WeatherQuery.forecast('Malibu,US')
          WeatherQuery.forecast('Beijing,CN', false)
          WeatherQuery.forecast('Delhi,IN', false)

          actual = WeatherQuery.send(:cache).keys
          expect(actual).to eq(['Malibu,US'])
        end
      end
  end

  describe 'query history' do
    before do
      WeatherQuery.clear!

      expect(WeatherQuery.history).to eq([])
      allow(WeatherQuery).to receive(:http).and_return('{}')
    end

    after do
      WeatherQuery.clear!
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

      places.each {|s| WeatherQuery.forecast(s) }

      expect(WeatherQuery.history).to eq(places)
    end

    it "does not allow history to be modified" do
      expect {
        WeatherQuery.history = ['Malibu,CN']
      }.to raise_error(NoMethodError)

      expect(WeatherQuery.history).to eq([])
    end
  end

  describe 'number of API requests' do
    before do
      WeatherQuery.clear!

      expect(WeatherQuery.history).to eq([])
      allow(WeatherQuery).to receive(:http).and_return('{}')
    end

    after do
      WeatherQuery.clear!
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

      places.each {|s| WeatherQuery.forecast(s) }

      expect(WeatherQuery.api_request_count).to eq(3)
    end

    it "does not allow history to be modified" do
      expect {
        WeatherQuery.api_request_count = 100
      }.to raise_error(NoMethodError)

      expect {
        WeatherQuery.api_request_count += 10
      }.to raise_error(NoMethodError)

      expect(WeatherQuery.api_request_count).to eq(0)
    end
  end

  describe '.forecast' do
    context 'network errors' do
      let(:custom_error) { WeatherQuery::NetworkError }

      before do
        expect(Net::HTTP).to receive(:get).and_raise(error_to_raise)
      end

      context 'timeouts' do
        let(:error_to_raise) { Timeout::Error }

        it "raises a NetworkError instead of Timeout::Error" do
          expect{
            WeatherQuery.forecast('Antarctica')
          }.to raise_error(custom_error, "Request timed out")
        end
      end

      context 'invalid URI' do
        let(:error_to_raise) { URI::InvalidURIError }

        it "raises a NetworkError instead of URI::InvalidURIError" do
          expect{
            WeatherQuery.forecast('Antarctica')
          }.to raise_error(custom_error, "Bad place name: Antarctica")
        end
      end

      context 'socket errors' do
        let(:error_to_raise) { SocketError }

        it "raises a NetworkError instead of SocketError" do
          expect{
            WeatherQuery.forecast('Antarctica')
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
        expect(WeatherQuery).to receive(:http)
          .with('Antarctica')
          .and_return(xml_response)

        expect{
          WeatherQuery.forecast('Antarctica')
        }.to raise_error(
          WeatherQuery::NetworkError, "Bad response"
        )
      end
    end
  end
end
