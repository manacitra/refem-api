# frozen_string_literal: true

require 'dry/transaction'

module RefEm
  module Service
    # Transaction to store project from MS API to database
    class ShowPaperList
      include Dry::Transaction

      step :find_paper

      private

      MS_NOT_FOUND_MSG = 'Could not find that paper on Microsoft'
      MS_NOT_FOUND_BY_KEYWORD_MSG = 'Could not find papers by the keyword or search type'

      # Expects input[:keyword] and input[:searchType]
      def find_paper(input)
        begin
          input[:papers] = paper_from_microsoft(input)
          unless input[:papers] == []
            Value::PaperList.new(input[:papers])
              .yield_self do |papers|
                Success(Value::Result.new(status: :ok, message: papers))
              end
          else
            Failure(Value::Result.new(status: :not_found,
                                      message: MS_NOT_FOUND_MSG))
          end
        rescue StandardError => error
          Failure(Value::Result.new(status: :internal_error,
                                    message: MS_NOT_FOUND_BY_KEYWORD_MSG))
        end
      end

      # following are support methods that other services could use

      def paper_from_microsoft(input)
        MSPaper::PaperMapper
          .new(Api.config.MS_TOKEN)
          .find_papers_by_keywords(input[:keyword], input[:searchType])
      end
    end
  end
end
