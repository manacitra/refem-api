# frozen_string_literal: true

require 'http'
# Namespace for entire library
module RefEm
  # Library for Semantic Scholar  API
  module MSPaper
    # Library for Semantic Scholar Search API
    class SSApi
      def initialize; end

      def paper_data(doi)
        Request.new.ss_paper_data(doi).parse
      end

      

      # Class to request from API, no key needed
      class Request
        LOOKUP_PATH = 'http://api.semanticscholar.org/v1/paper/'
        def initialize; end

        def ss_paper_data(doi)
          get(LOOKUP_PATH + doi.to_s)
        end

        def get(url)
          http_response = HTTP.headers(
            'Accept' => 'application/json'
          ).get(url)
        end
      end
      # Class to get http response from API
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        HTTP_ERROR = {
          404 => NotFound
        }.freeze
        def successful?
          HTTP_ERROR.keys.include?(code) ? false : true
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
