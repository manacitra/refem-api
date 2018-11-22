# frozen_string_literal: true

require 'dry-validation'

module RefEm
  module Forms
    Keyword = Dry::Validation.Params do
      KEYWORD_REGEX = %r{[a-zA-Z]}

      required(:keyword).filled(format?: KEYWORD_REGEX)

      configure do
        config.messages_file = File.join(__dir__, 'errors/keyword_search.yml')
      end
    end
  end
end
