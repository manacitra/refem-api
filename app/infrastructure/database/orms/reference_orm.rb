# frozen_string_literal: true

require 'sequel'

module RefEm
  module Database
    # Object Relational Mapper for Reference Entities
    class ReferenceOrm < Sequel::Model(:referencess)
      many_to_many :reference_main_papers,
                   class:      :'RefEm::Database::PaperOrm',
                   join_table: :referencess_papers,
                   left_key:   :references_id, right_key: :paper_id

      plugin :timestamps, update_on_create: true
    end
  end
end
