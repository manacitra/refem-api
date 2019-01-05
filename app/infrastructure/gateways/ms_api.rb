# frozen_string_literal: true

require 'net/http'
require 'yaml'
require 'json'
# Load data parsing class
# require_relative 'paper_info.rb'

# Namespace for entire library
module RefEm
  # Library for Microsoft Academic Web API; Web API class
  module MSPaper
    # Library for Microsoft Academic Search API
    class Api
      def initialize(token)
        @ms_token = token
      end

      # parse data from response with keywords input
      def full_paper_data(keywords, searchType)
        paper_response = Request.new(@ms_token).full_paper_info(keywords, searchType)
        create_new_data_format(JSON.parse(paper_response.body))
      end

      # parse data from response with id input
      def paper_data(id)
        paper_response = Request.new(@ms_token).paper_info(id)
        create_new_data_format(JSON.parse(paper_response.body))
      end

      def reference_data(references)
        paper_response = Request.new(@ms_token).reference_info(references)
        create_new_data_format(JSON.parse(paper_response.body))
      end

      def create_new_data_format(res_data)
        res_data['entities'].map { |data|
          author_array = []
          field_array = []
          reference_array = []
          data['AA'].map { |author|
            author_array.push(author['AuN'])
          }
          data['AA'] = author_array
          data['F'].map { |field|
            field_array.push(field['FN'])
          }
          data['F'] = field_array
          if (!data['RId'].nil?)
            data['RId'].map { |rid|
              reference_array.push(rid.to_s)
            }
          end
          data['RId'] = reference_array
          data['E'] = JSON.parse(data['E'])
        }
        res_data['entities']
      end

      # send out HTTP requests to Github
      class Request
        # Initialize API library with token and cache object
        def initialize(token, cache: {})
          @token = token
          @cache = cache
        end

        # request based on keywords
        def full_paper_info(keywords, searchType)
          keyword = concat_keywords(keywords, searchType)
          uri = URI('https://api.labs.cognitive.microsoft.com/academic/v1.0/evaluate')
          query = URI.encode_www_form({
            # Request parameters
            'expr' => keyword,
            'model' => 'latest',
            'count' => "50",
            'offset' => '0',
            'attributes' => 'Id,Ti,AA.AuN,Y,D,F.FN,E,RId'
          })

          if uri.query && uri.query.length > 0
            uri.query += '&' + query
          else
            uri.query = query
          end

          get(uri)
        end

        def paper_info(id)
          uri = URI('https://api.labs.cognitive.microsoft.com/academic/v1.0/evaluate')
          query = URI.encode_www_form({
            # Request parameters
            'expr' => "Id=#{id}",
            'model' => 'latest',
            'offset' => '0',
            'attributes' => 'Id,Ti,AA.AuN,Y,D,F.FN,E,RId'
          })

          if uri.query && uri.query.length > 0
            uri.query += '&' + query
          else
            uri.query = query
          end

          get(uri)
        end

        def reference_info(references)
          ref_array = concat_references(references)
          # puts ref_array
          uri = URI('https://api.labs.cognitive.microsoft.com/academic/v1.0/evaluate')
          query = URI.encode_www_form({
            # Request parameters
            'expr' => "Or(#{ref_array})",
            'model' => 'latest',
            'count' => "100",
            'offset' => '0',
            'attributes' => 'Id,Ti,AA.AuN,Y,D,F.FN,E,RId,CC'
          })

          if uri.query && uri.query.length > 0
            uri.query += '&' + query
          else
            uri.query = query
          end
          get(uri)
        end

        def concat_references(references)
          ref_array = ''
          references.map { |data|
            ref_array = ("Id=#{data}") if ref_array == ""
            ref_array = (ref_array + ", Id=#{data}") if ref_array != ""
          }
          ref_array
        end

        def concat_keywords(keyword, searchType)
          keyword_array = ''
          if searchType == 'keyword' 
            # split keyword by white space
            keywords = keyword.split('%20')

            keywords.map { |data|
              if keyword_array == ''
                keyword_array = ("W=='#{data}'") 
              else
                keyword_array = (keyword_array + ", W=='#{data}'") if keyword_array != ""
              end
            }
            keyword_array = "Or(#{keyword_array})"
          else # search type is 'title'
            title = keyword.gsub! '%20', ' '
            keyword_array = "Ti=='#{title}'"
          end
          keyword_array
        end

        def get(uri)
          http_request = Net::HTTP::Get.new(uri.request_uri)
          # Request headers
          http_request['Ocp-Apim-Subscription-Key'] = @token
          # Request body
          http_response = @cache.fetch(uri) do
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
              http.request(http_request)
            end
          end

          Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
        end
      end

      # Decorates HTTP responses from microsoft academic search with success/error
      class Response < SimpleDelegator
        Unauthorized = Class.new(StandardError)
        BadRequest = Class.new(StandardError)

        HTTP_ERROR = {
          '401' => Unauthorized,
          '400' => BadRequest
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
