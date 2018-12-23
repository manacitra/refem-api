# frozen_string_literal: true

module RefEm
  module RouteHelpers
    # Application value for the path of a requested paper
    class PaperRequestPath
      def initialize(keyword, searchType)
        @keyword = keyword
        @searchType = searchType
      end

      attr_reader :keyword, :searchType
    end
  end
end
