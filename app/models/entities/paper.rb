# frozen_string_literal: true

require_relative 'reference.rb'
require_relative 'citation.rb'

module RefEm
  module Entity
    # Domain entity for paper
    class Paper < Dry::Struct
      include Dry::Types.module

      attribute :id,          Integer.optional
      attribute :origin_id,   Strict::Integer
      attribute :title,       Strict::String
      attribute :author,      Strict::String
      attribute :year,        Strict::Integer
      attribute :date,        Strict::String
      attribute :field,       Strict::String
      attribute :references,  Array.of(Reference).optional
      attribute :citations,   Array.of(Citation).optional
      attribute :doi,         Strict::String.optional
      # attribute :citation_velocity, Strict::Integer
      # attribute :influential_citation_count, Strict::Integer

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :references, :citations].include? key }
      end

      # def ref_to_array
      #   reference_array = references.split(";")
      # end
    end
  end
end
