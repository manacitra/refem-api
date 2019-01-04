# frozen_string_literal: true

require_relative 'reference.rb'
require_relative 'citation.rb'
require 'dry-types'
require 'dry-struct'

module RefEm
  module Entity
    # Domain entity for paper
    class Paper < Dry::Struct
      include Dry::Types.module

      attribute :id,          Strict::Integer.optional
      attribute :origin_id,   Strict::Integer
      attribute :title,       Strict::String.optional
      attribute :author,      Strict::String.optional
      attribute :year,        Strict::Integer.optional
      attribute :date,        Strict::String.optional
      attribute :field,       Strict::String.optional
      attribute :refs,        Array.of(Reference).optional
      attribute :citations,   Array.of(Citation).optional
      attribute :doi,         Strict::String.optional
      attribute :link,        Strict::String.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :refs, :citations].include? key }
      end
    end
  end
end
