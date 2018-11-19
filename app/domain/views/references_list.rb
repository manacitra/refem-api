# frozen_string_literal: true

require_relative 'reference'

module Views
  # View for a list of reference entities
  class ReferenceList
    def initialize(references)
      @references = references.map.with_index { |r, i| Reference.new(r, i)}
    end

    def each
      @references.each do |r|
        yield r
      end
    end
  end
end
