# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module RefEm
  module Representer
    # Represents Citation information for API output
    class CitationJSON < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :title
      property :author
      property :year
      property :doi
      property :venue
      property :influential_citation_count
      property :link


    end
  end
end
