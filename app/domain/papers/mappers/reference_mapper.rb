# frozen_string_literal: true

require 'json'

module RefEm
  # Provides access to microsoft data
  module MSPaper
    # Data Mapper: microsoft paper -> paper
    class ReferenceMapper
      def initialize(ms_token, gateway_class = MSPaper::Api)
        @token = ms_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def load_several(references, reference_contents)
        # puts references
        references_array = []

        @gateway.reference_data(references).each do |data|
          reference_id = data['Id'].to_s
          unless reference_contents[reference_id].nil? 
            reference_content = reference_contents[reference_id][0] 
          else 
            reference_content = ""
          end
          
          reference = ReferenceMapper.build_entity(data, reference_content)
          references_array.push(reference)
          
          # ReferenceMapper.build_entity(data, 'good')
        end
        references_array
      end

      def self.build_entity(data, content)
        DataMapper.new(data, content).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, content)
          @data = data
          @reference_content = content
        end

        def build_entity
          RefEm::Entity::Reference.new(
            id: nil,
            origin_id: origin_id,
            title: title,
            author: author,
            year: year,
            date: date,
            references: references,
            field: field,
            doi: doi,
            venue_full: venue_full,
            volume: volume,
            journal_name: journal_name,
            citation_count: citation_count,
            reference_content: reference_content,
            link: link
          )
        end

        private

        def origin_id
          @data['Id']
        end

        def author
          author = ''
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

        def references
          reference = ''
          if @data['RId'] != nil
            @data['RId'].each { |r|
              reference += "#{r};"
            }
          end
          reference
        end

        def field
          field = ''
          @data['F'].each { |f|
            field += "#{f};"
          }
          field
        end

        def citation_count
          @data['CC']
        end

        def doi
          @data['E']['DOI']
        end

        def venue_full
          @data['E']['VFN']
        end

        def volume
          @data['E']['V']
        end

        def journal_name
          @data['E']['BV']
        end

        def reference_content
          @reference_content
        end

        def link
          "https://academic.microsoft.com/#/detail/#{@data['Id']}"
        end
      end
    end
  end
end
