# frozen_string_literal: true

require 'json'
require_relative 'ss_mapper'

module RefEm
  # Provides access to microsoft data
  module MSPaper
    # Data Mapper: microsoft paper -> paper
    class PaperMapper
      #include RefEm::SSPaper
      def initialize(ms_token, gateway_class = MSPaper::Api)
        @token = ms_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(keywords, count)
        data = @gateway.paper_data(keywords, count)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @gateway_class).build_entity
      end
      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, gateway_class)
          @data = data
          @msmapper = PaperMapper.new(gateway_class)
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
            doi: doi,
            citation_velocity: citation_velocity,
            citation_dois: citation_dois,
            citation_titles: citation_titles,
            influential_citation_count: influential_citation_count,
            venue: venue
          )
        end

<<<<<<< HEAD
        def id
          @data.first['Id']
        end

        def title
          @data.first['Ti']
=======
        def origin_id
          @data['Id']
        end

        def author
          author = ""
          @data['AA'].each { |auth|
            author += "#{auth};"
          }
          author
>>>>>>> 6132d80d6cd864a4363a7328a27d264fa65ce1fb
        end

        def author
          @data.first['AA']
        end

        def year
          @data.first['Y']
        end

        def date
          @data.first['D']
        end

        def field
<<<<<<< HEAD
          @data.first['F']
=======
          field = ""
          @data['F'].each { |f|
            field += "#{f};"
          }
          field
>>>>>>> 6132d80d6cd864a4363a7328a27d264fa65ce1fb
        end

        def doi
          @data.first['E']['DOI']
        end

        # get_from_ss = RefEm::SSPaper::SSMapper.new
        # .find_data_by(@data['E']['DOI'])

        def citation_velocity
          RefEm::SSPaper::SSMapper.new
                                  .find_data_by(@data.first['E']['DOI'])
                                  .citation_velocity
        end

        def citation_dois
          RefEm::SSPaper::SSMapper.new
                                  .find_data_by(@data.first['E']['DOI'])
                                  .citation_dois
        end

        def citation_titles
          RefEm::SSPaper::SSMapper.new
                                  .find_data_by(@data.first['E']['DOI'])
                                  .citation_dois
        end

        def influential_citation_count
          RefEm::SSPaper::SSMapper.new
                                  .find_data_by(@data.first['E']['DOI'])
                                  .influential_citation_count
        end

        def venue
          RefEm::SSPaper::SSMapper.new
                                  .find_data_by(@data.first['E']['DOI'])
                                  .venue
        end
      end
    end
  end
end
