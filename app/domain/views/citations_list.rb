# frozen_string_literal: true

require_relative 'citation'

module Views
  # View for a list of citation entities
  class CitationList
    def initialize(citations)
      @citations = citations.map.with_index { |c, i| Citation.new(c, i)}
    end

    def each
      @citations.each do |c|
        yield c
      end
    end
  end
end
