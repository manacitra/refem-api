# frozen_string_literal: true

require 'json'
require_relative 'citation_mapper'

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

      def find_full_paper(keywords, count)
        paper_array = []
        paper_count = 0
        full_find = true
        # get all paper information
        # filter that nil Rid and nil DOI
        # build Entity
        @gateway.full_paper_data(keywords, 20).map { |data|
          unless paper_count == 10 || data['RId'] == [] || data['E']['DOI'] == nil
            paper_array.push(build_entity(data, full_find)) 
            paper_count += 1
          end
        }
        paper_array
      end

      def find_paper(id)
        full_find = false
        @gateway.paper_data(id).map { |data|
          build_entity(data, full_find) 
        }
      end

      def build_entity(data, kind_of_find)
        DataMapper.new(data, @token, @gateway_class, kind_of_find).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class, kind_of_find)
          @data = data
          @kind_of_find = kind_of_find
          @reference_mapper = ReferenceMapper.new(
            token, gateway_class
          )
          @citation_mapper = CitationMapper.new
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
            references: references,
            citations: citations,
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

        # connect with reference mapper
        def references
          @reference_mapper.load_several(@data['RId']) unless @kind_of_find
        end

        def citations
          @citation_mapper.find_data_by(@data['E']['DOI'])
        end

        def doi
          @data['E']['DOI']
        end
      end
    end
  end
end
