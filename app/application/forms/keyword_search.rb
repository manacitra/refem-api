# frozen_string_literal: true

require 'dry-validation'

module RefEm
  module Forms
    Keyword = Dry::Validation.Params do
      # only allows alphabet and space for title
      KEYWORD_REGEX = /^[a-zA-Z][\sa-zA-Z | %20]*$/

      required(:keyword).filled(format?: KEYWORD_REGEX)
      required(:searchType).filled(format?: KEYWORD_REGEX)
      

      configure do
        config.messages_file = File.join(__dir__, 'errors/keyword_search.yml')
      end
    end
  end
end
