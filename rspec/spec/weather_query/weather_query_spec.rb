
require 'weather_query/weather_query'

describe WeatherQuery do
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
