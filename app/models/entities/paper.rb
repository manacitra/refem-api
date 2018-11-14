# frozen_string_literal: true
require_relative 'reference.rb'

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
      attribute :doi,         Strict::String.optional

#      attribute :references,  Strict::Array.member(Paper).optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :references].include? key }
      end
      
      # def ref_to_array
      #   reference_array = references.split(";")    
      # end
    end
  end
end
