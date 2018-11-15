# frozen_string_literal: true

require 'sequel'

module RefEm
  module Database
    # Object Relational Mapper for Reference Entities
    class ReferenceOrm < Sequel::Model(:references)
      many_to_many :reference_main_paper,
                  class:      :'RefEm::Database::PaperOrm',
                  join_table: :renferences_papers,
                  left_key:   :reference_id, right_key: :paper_id

      plugin :timestamps, update_on_create: true
    end
  end
end
