module Blocktrain
  class Aggregation
    def initialize(options = {})
      @lookups = Lookups.instance.lookups
      @signal = options[:signal]
      @sub_signal = options[:sub_signal]

      @from = parse_datetime(options.fetch(:from, '2015-09-01T00:00:00'))
      @to = parse_datetime(options.fetch(:to, '2015-09-02T00:00:00'))

      @interval = options.fetch(:interval, '10m')
    end

    def results
      Client.results(body)['aggregations']
    end

    def parse_datetime(datetime)
      utc = Time.parse(datetime).utc
      return utc.to_i * 1000
    end

    def address_query
      if @lookups[@signal].is_a?(Hash)
        if @sub_signal.nil?
          @lookups[@signal].map { |k, v| "memoryAddress:#{v}" }.join(' OR ')
        else
          "memoryAddress:#{@lookups[@signal][@sub_signal]}"
        end
      else
        "memoryAddress:#{@lookups[@signal]}"
      end
    end

    def query
      {
        filtered: {
          query: {
            query_string: {
              analyze_wildcard: true,
              query: address_query
            }
          },
          filter: {
            bool: {
              must: [
                {
                  range: {
                    timeStamp: {
                      gte: @from,
                      lte: @to
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def aggs
      {
        results: {
          date_histogram: {
            field: 'timeStamp',
            interval: @interval,
            time_zone: '+01:00',
            min_doc_count: 1,
            extended_bounds: {
              min: @from,
              max: @to
            }
          },
          aggregations: local_aggregations
        }
      }
    end

    def body
      {
        query: query,
        size: 0,
        aggregations: aggs,
      }
    end
  end
end
