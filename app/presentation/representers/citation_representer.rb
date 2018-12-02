# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module RefEm
  module Representer
    # Represents Citation information for API output
    class Citation < Roar::Decorator
      include Roar::JSON
      property :title
      property :author
      property :year
      property :venue
      property :doi
    end
  end
end
