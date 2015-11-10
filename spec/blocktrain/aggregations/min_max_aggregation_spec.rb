module Blocktrain
  module Aggregations
    describe MinMaxAggregation do

      describe 'hour long histogram' do

        subject(:aggregations) {
          described_class.new(from: '2015-09-01 10:00:00Z', to: '2015-09-01 11:00:00Z', signal: 'passenger_load').results
        }

        it 'has an aggregation called weight_chart', :vcr do
          expect(aggregations).to have_key 'results'
          expect(aggregations['results']).to have_key 'buckets'
          expect(aggregations['results']['buckets'].count).to eq 6
          expect(aggregations['results']['buckets'][0]['value']['buckets'][0].keys).to include 'max_value', 'min_value', 'average_value'
          expect(aggregations['results']['buckets'][2]['value']['buckets'][2]['average_value']['value']).to be_within(0.1).of 4.04
        end

      end
    end
  end
end