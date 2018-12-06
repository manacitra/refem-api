# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'citation_representer.rb'

module RefEm
  module Representer
    # Represents Reference information for API output
    class Reference < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer
      # reference use the same structure as citation
      # property :citation, extend: Representer::Citation, class: OpenStruct
      property :title
     
      link :self do
        "https://academic.microsoft.com/#/detail/#{origin_id}"
      end

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
