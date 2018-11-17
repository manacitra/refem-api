# frozen_string_literal: true

require_relative 'paper'

module Views
  # View for a list of paper entities
  class PaperList
    def initialize(papers, keyword)
      @papers = papers.map.with_index { |p, i| Paper.new(p, keyword, i)}
    end

    def each
      @papers.each do |p|
        yield p
      end
    end
  end
end
