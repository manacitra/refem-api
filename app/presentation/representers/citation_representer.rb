# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module RefEm
  module Representer
    # Represents Citation information for API output
    class Citation < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer
      property :title
      # property :author
      # property :year
      # property :venue
      property :doi

      link :self do
        "https://api.semanticscholar.org/#{origin_id}"
      end

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
