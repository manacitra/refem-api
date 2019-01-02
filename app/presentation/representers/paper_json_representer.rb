# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'citation_json_representer'
require_relative 'reference_json_representer'

module RefEm
  module Representer
    # Represents Paper information for API output
    class PaperJSON < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :title
      property :author
      property :year
      property :date
      property :field
      property :doi
      property :link
      collection :citations, extend: Representer::CitationJSON, class: OpenStruct
      collection :references, extend: Representer::ReferenceJSON, class: OpenStruct

      link :self do
        "#{Api.config.API_HOST}/api/v1/paper/#{origin_id}/"
      end

      private

      def origin_id
        represented.origin_id
      end

    end
  end
end
