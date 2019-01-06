# frozen_string_literal: true

require 'json'

module RefEm
  # Provides access to microsoft data
  module MSPaper

    # Data Mapper: microsoft paper -> paper
    class PaperJsonMapper
      def initialize(data)
        @data = data
      end

      def build_entity
        DataMapper.new(@data).build_entity
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
            doi: doi,
            refs: references,
            citations: citations,
            link: link
          )
        end

        def origin_id
          @data[:origin_id].to_s
        end

        def author
          @data[:author]
        end

        def title
          @data[:title]
        end

        def year
          @data[:year]
        end

        def date
          @data[:date]
        end

        def field
          @data[:field]
        end

        # connect with reference mapper
        def references
          @data[:refs].map { |ref|
            ref[:id] = nil
            ref[:doi] = nil if ref[:doi].nil?
            ref[:volume] = nil if ref[:volume].nil?
            ref[:journal_name] = nil if ref[:journal_name].nil?
            RefEm::Entity::Reference.new(ref)
          }
        end

        def citations
          @data[:citations].map { |cit|
            cit[:id] = nil
            cit[:doi] = nil if cit[:doi].nil?
            cit[:year] = nil if cit[:year].nil?
            RefEm::Entity::Citation.new(cit)
          }
        end

        def doi
          @data[:doi]
        end

        def link
          @data[:link]
        end
      end
    end
  end
end
