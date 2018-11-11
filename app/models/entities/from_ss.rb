# frozen_string_literal: true

module RefEm
  module Entity
    # Domain entity for paper
    class FromSS < Dry::Struct
      include Dry::Types.module

      attribute :citation_velocity,            Strict::Integer
      attribute :citations_doi,                Strict::Array.of(String) # sometimes doi is null
      attribute :citations_title,              Strict::Array.of(String)
      attribute :influential_citation_count,   Strict::Integer
      attribute :venue,                        Strict::String
      attribute :focus_doi,                    Strict::String # Paper that we interested in
    end
  end
end
