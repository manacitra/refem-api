# frozen_string_literal: true

require 'sequel'

module RefEm
  module Database
    # Object Relational Mapper for Paper Entities
    class PaperOrm < Sequel::Model(:papers)
      many_to_many :reference,
                  class: :'RefEm::Database::ReferenceOrm'
                  join_table: :references_papers,
                  left_key: :paper_id, right_key: :reference_id

      many_to_many :citation_doi,
                  class: :'RefEm::Database::CitationOrm'
                  join_table: :citations_papers,
                  left_key: :paper_id, right_key: :citation_id
      
      
      plugin :timestamps, update_on_create: true
    end
  end
end
