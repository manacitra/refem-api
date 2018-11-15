# frozen_string_literal: true

require 'json'

module RefEm
  # Provides access to microsoft data
  module MSPaper
    # Data Mapper: microsoft paper -> paper
    class CitationMapper
      def initialize(gateway_class = RefEm::MSPaper::SSApi)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find_data_by(doi)
        puts "================="
        puts "asuuuuuuu"
        puts doi
        data = @gateway.paper_data(doi)
        
        puts "konto;;;;;;;;;;;;;;;;;;;;;;;"
        puts data["error"]
        build_entity(data) unless data["error"]
      end

      def build_entity(data)
        DataMapper.new(data, @gateway_class).build_entity
      end
      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, gateway_class)
          @data = data
          @ssmapper = CitationMapper.new(gateway_class)
        end

        def build_entity
          RefEm::Entity::Citation.new(
            id: nil,
            doi: doi,
            citation_velocity: citation_velocity,
            citation_dois: citation_dois,
            citation_titles: citation_titles,
            influential_citation_count: influential_citation_count,
            venue: venue,
          )

          #paper id from paper table as foreign key
        end

        private

        def id
          @data['id']
        end

        def citation_velocity
          @data['citationVelocity']
        end

        def citation_dois
          @data['citations'].map { |n| n['doi'] }.compact
        end

        def citation_titles
          @data['citations'].map { |n| n['title'] }.compact
        end

        def influential_citation_count
          @data['influentialCitationCount']
        end

        def venue
          @data['venue']
        end

        def doi
          @data['doi']
        end
      end
    end
  end
end
