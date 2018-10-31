# frozen_string_literal: true

module RefEm
  module Entity
  # Domain entity for paper
    class Paper < Dry::Struct
      include Dry::Types.module

      attribute :id,    Strict::Integer
      attribute :paper_year,    Strict::Integer
      attribute :paper_date,    Strict::String
      attribute :paper_doi,    Strict::String
    end
  end
end
