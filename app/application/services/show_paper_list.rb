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

      # Expects input[:keyword] and input[:searchType]
      def find_paper(input)
        begin
          input[:papers] = paper_from_microsoft(input)
          unless input[:papers] == []
            Success(input)
          else
            raise 'Could not find papers by the keyword'
          end
        rescue StandardError => error
          Failure(Value::Result.new(status: :not_found,
                                    message: :error.to_s))
        end
      end

      # following are support methods that other services could use

      def paper_from_microsoft(input)
        MSPaper::PaperMapper
          .new(App.config.MS_TOKEN)
          .find_papers_by_keywords(input[:keyword], input[:searchType])
      rescue StandardError
        raise MS_NOT_FOUND_MSG
      end

      def project_in_database(input)
        Repository::For.klass(Entity::Paper)
      end
    end
  end
end
