module Blocktrain
  class Query

    def initialize(options = {})
      @memory_address = options.fetch(:memory_address, nil)
      @signal = options[:signal]

      @from = parse_datetime(options.fetch(:from, '2015-09-01T00:00:00'))
      @to = parse_datetime(options.fetch(:to, '2015-09-02T00:00:00'))
      
      @limit = options.fetch(:limit, 100)
    end

    def results
      result['hits']['hits']
    end
    
    def hits 
      result['hits']['total']
    end

    def parse_datetime(datetime)
      utc = Time.parse(datetime).utc
      return utc.to_i * 1000
    end

    def address_query
      # Look up memory addresses directly if specified
      return "memoryAddress:#{@memory_address}" if @memory_address
      # No query if there isn't a signal specified
      return nil if @signal.nil?
      # Find the right memory address
      lookups = Lookups.instance.lookups
      "memoryAddress:#{lookups[@signal]}"
    end

    def query
      {
        filtered: {
          query: filtered_query,
          filter: filtered_filter
        }
      }
    end
    
    def filtered_query
      q = address_query
      return {} if q.nil?
      {
        query_string: {
          query: q
        }
      }
    end
    
    def filtered_filter
      {
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
    end

    def body
      {
        query: query,
        size: @limit
      }
    end

    private

      def result
        Client.results(body)
      end

  end
end
