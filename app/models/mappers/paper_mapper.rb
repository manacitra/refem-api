# frozen_string_literal: true
require 'json'

module RefEm
  # Provides access to microsoft data
  module MSPaper
    # Data Mapper: microsoft paper -> paper
    class PaperMapper
      def initialize(ms_token, gateway_class = MSPaper::Api)
        @token = ms_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(keywords, count)
        @gateway.paper_data(keywords, count).map { |data|
          build_entity(data)
        }
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end
      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          RefEm::Entity::Paper.new(
            id: nil,
            origin_id: origin_id,
            title: title,
            author: author,
            year: year,
            date: date,
            field: field,
            doi: doi
          )
        end

        def origin_id
          @data['Id']
        end

        def author
          author = ""
          @data['AA'].each { |auth|
            author += "#{auth};"
          }
          author
        end

        def title
          @data['Ti']
        end

        def year
          @data['Y']
        end

        def date
          @data['D']
        end

        def field
          field = ""
          @data['F'].each { |f|
            field += "#{f};"
          }
          field
        end

        def doi
          @data['E']['DOI']
        end
      end
    end
  end
end
