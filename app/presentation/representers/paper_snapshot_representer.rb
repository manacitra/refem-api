# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'citation_representer'
require_relative 'reference_representer'

module RefEm
  module Representer
    # Represents small paper information for paper list
    class PaperSnapshot < Roar::Decorator
      include Roar::JSON
      property :title
      property :author
      property :year
      property :doi
    end
  end
end

