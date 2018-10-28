# frozen_string_literal: true
require 'json'

module MSAcademic
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
            data = @gateway.paper_data(keywords, count)
            build_entity(data)
        end

        def build_entity(data)
          DataMapper.new(data).build_entity
        end
        
        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data['entities'][0]
          end

          def build_entity
            MSAcademic::Entity::Paper.new(
              id: id,
              paper_year: year,
              paper_date: date,
              paper_doi: doi
            )
          end

          def id
            @data['Id']
          end

          def year
            @data['Y']
          end

          def date
            @data['D']
          end

          def doi
            @data['E']['DOI']
          end
        end
    end
  end
end
