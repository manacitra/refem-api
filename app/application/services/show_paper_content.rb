# frozen_string_literal: true

require 'dry/transaction'

module RefEm
  module Service
    # Transaction to store paper from MS API to database
    class ShowPaperContent
      include Dry::Transaction

      step :find_main_paper
      step :store_paper

      private

      def find_main_paper(input)
        if (paper = paper_in_database(input))
          input[:local_paper] = paper
        else
          input[:remote_paper] = paper_from_microsoft(input)[0]
        end

        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_paper(input)
        paper =
          if (new_paper = input[:remote_paper])
            Repository::For.entity(new_paper).create(new_paper)
          else
            input[:local_paper]
          end
        Success(paper)
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def paper_from_microsoft(input)
        MSPaper::PaperMapper
          .new(App.config.MS_TOKEN)
          .find_paper(input[:id])
      rescue StandardError
        raise 'Could not find papers by the ID'
      end

      def paper_in_database(input)
        Repository::For.klass(Entity::Paper)
          .find_paper_content(input[:id])
      end
    end
  end
end
