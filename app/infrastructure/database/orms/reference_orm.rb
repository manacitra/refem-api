# frozen_string_literal: true

require 'sequel'

module RefEm
  module Database
    # Object Relational Mapper for Reference Entities
    class ReferenceOrm < Sequel::Model(:refpapers)
      many_to_many :reference_main_papers,
                   class:      :'RefEm::Database::PaperOrm',
                   join_table: :refpapers_papers,
                   left_key:   :refpaper_id, right_key: :paper_id

      plugin :timestamps, update_on_create: true
    end
  end
end
