# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'citation_representer.rb'

module RefEm
  module Representer
    # Represents Reference information for API output
    class ReferenceJSON < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :title
      property :author
      property :year
      property :date
      property :references
      property :field
      property :doi
      property :venue_full
      property :volume
      property :journal_name
      property :citation_count
      property :reference_content
      property :link

    end
  end
end
