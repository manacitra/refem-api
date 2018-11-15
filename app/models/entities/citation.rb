# frozen_string_literal: true

module RefEm
  module Entity
    # Domain entity for paper
    class Citation < Dry::Struct
      include Dry::Types.module

      attribute :id,                           Integer.optional
      attribute :citation_velocity,            Strict::Integer
      attribute :citation_dois,                Strict::Array.of(String) # sometimes doi is null
      attribute :citation_titles,              Strict::Array.of(String)
      attribute :influential_citation_count,   Strict::Integer
      attribute :venue,                        Strict::String
      attribute :doi,                    Strict::String # Paper that we interested in

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key}
      end
    end
  end
end
