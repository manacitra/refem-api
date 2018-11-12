# frozen_string_literal: true

require 'sequel'

module RefEm
  module Database
    # Object Relational Mapper for Reference Entities
    class CitationOrm < Sequel::Model(:citations)
      many_to_many :papers,
                  class: :'RefEm::Database::PaperOrm',
                  join_table: :citations_papers,
                  left_key: :citation_id, right_key: :paper_id

      plugin :timestamps, update_on_create: true
    end
  end
end
