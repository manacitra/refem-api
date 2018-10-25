# frozen_string_literal: true
require 'json'

module MSAcademic
  # Model to get paper's ID, Year, Date, DOI
  class MSPaper
    def initialize(paper_data, data_source)
      paper_res_data = JSON.parse(paper_data)
      paper_entity_data = paper_res_data['entities']
      @entity_data = paper_entity_data[0]
    end

    def paper_id
        @entity_data['Id']
    end

    def paper_year
      @entity_data['Y']
    end

    def paper_date
      @entity_data['D']
    end

    def paper_doi
      extend_data = JSON.parse(@entity_data['E'])
      @doi = extend_data['DOI']
    end
  end
end
