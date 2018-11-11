# frozen_string_literal: true

module RefEm
  module Entity
    # Domain entity for paper
    class Paper < Dry::Struct
      include Dry::Types.module

<<<<<<< HEAD
      attribute :id,          Strict::Integer.optional
      attribute :title,       Strict::String
      attribute :author,      Strict::Array.of(String)
      attribute :year,        Strict::Integer.optional
      attribute :date,        Strict::String.optional
      attribute :field,       Strict::Array.of(String).optional
=======
      attribute :id,          Integer.optional
      attribute :origin_id,   Strict::Integer
      attribute :title,       Strict::String
      attribute :author,      Strict::String
      attribute :year,        Strict::Integer
      attribute :date,        Strict::String
      attribute :field,       Strict::String
>>>>>>> 6132d80d6cd864a4363a7328a27d264fa65ce1fb
      attribute :doi,         Strict::String.optional
      attribute :citation_velocity,            Strict::Integer.optional
      attribute :citation_dois,                Strict::Array.of(String).optional # sometimes doi is null
      attribute :citation_titles,              Strict::Array.of(String).optional
      attribute :influential_citation_count,   Strict::Integer.optional
      attribute :venue,                        Strict::String.optional

#      attribute :references,  Strict::Array.member(Paper).optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
      
    end
  end
end
