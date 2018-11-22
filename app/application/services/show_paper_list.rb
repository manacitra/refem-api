# frozen_string_literal: true

require 'dry/transaction'

module RefEm
  module Service
    # Transaction to store project from Github API to database
    class ShowPaperList
      include Dry::Transaction

      step :validate_input
      step :find_paper

      private

      def validate_input(input)
        if input.success?
          keyword = input[:keyword].split
          Success(owner_name: owner_name, project_name: project_name)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def find_project(input)
        if (project = project_in_database(input))
          input[:local_project] = project
        else
          input[:remote_project] = project_from_github(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      # following are support methods that other services could use

      def project_from_github(input)
        Github::ProjectMapper
          .new(App.config.GITHUB_TOKEN)
          .find(input[:owner_name], input[:project_name])
      rescue StandardError
        raise 'Could not find that keyword'
      end

      def project_in_database(input)
        Repository::For.klass(Entity::Paper)

      end
    end
  end
end
