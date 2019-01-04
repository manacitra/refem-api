# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RefEm
  module Entity
    # Domain entity for paper
    class Reference < Dry::Struct
      include Dry::Types.module

      attribute :id,                 Strict::Integer.optional
      attribute :origin_id,          Strict::Integer
      attribute :title,              Strict::String
      attribute :author,             Strict::String.optional
      attribute :year,               Strict::Integer
      attribute :date,               Strict::String
      attribute :refs,               Strict::String.optional
      attribute :field,              Strict::String.optional
      attribute :doi,                Strict::String.optional
      attribute :venue_full,         Strict::String.optional
      attribute :volume,             Strict::Integer.optional
      attribute :journal_name,       Strict::String.optional
      attribute :citation_count,     Strict::Integer.optional
      attribute :reference_content,  Strict::String.optional
      attribute :link,               Strict::String.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
