# frozen_string_literal: true

module RefEm
  module RouteHelpers
    # Application value for the path of a requested paper
    class PaperRequestPath
      def initialize(id)
        @id = id
      end

      attr_reader :id
    end
  end
end
