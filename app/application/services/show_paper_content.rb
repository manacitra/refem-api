# frozen_string_literal: true

require 'dry/transaction'

module RefEm
  module Service
    # Transaction to store paper from MS API to database
    class ShowPaperContent
      include Dry::Transaction

      step :find_main_paper
      step :calculate_top_paper
      step :store_paper

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      MS_ID_NOT_FOUND = 'Could not find papers by the ID'

      def find_main_paper(input)
        if (paper = paper_in_database(input))
          puts "local paper"
          input[:local_paper] = paper
        else
          puts "remote paper"
          input[:remote_paper] = paper_from_microsoft(input)[0]
        end

        if (input[:local_paper].nil? && input[:remote_paper].nil?)
          Failure(Value::Result.new(status: :not_found, message: MS_ID_NOT_FOUND))
        else
          Success(input)
        end
      rescue StandardError => error
        Failure(Value::Result.new(status: :internal_error,
                                  message: MS_ID_NOT_FOUND))
      end

      def calculate_top_paper(input)
        if input[:local_paper].nil?
          paper = input[:remote_paper]
        else
          paper = input[:local_paper]
        end
        top_paper = MSPaper::TopPaperMapper.new(paper)
        # rank the references and citations
        paper = top_paper.top_papers

        
        if input[:local_paper].nil?
          input[:remote_paper] = paper
        else
          input[:local_paper] = paper
        end
      
        Success(input)
        # rescue StandardError
        #   raise 'Could not find papers by the ID'
      end

      def store_paper(input)
        paper =
          if (new_paper = input[:remote_paper])
            Repository::For.entity(new_paper).create(new_paper)
          else
            input[:local_paper]
          end
        
        Value::MainPaper.new(paper)
          .yield_self do |paper|
            Success(Value::Result.new(status: :ok, message: paper))
          end
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure(Value::Result.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # following are support methods that other services could use

      def paper_from_microsoft(input)
        MSPaper::PaperMapper
          .new(Api.config.MS_TOKEN)
          .find_paper(input[:id])
        # origin_id = input[:id]
        # paper = Entity::Paper.new(origin_id: origin_id)
        
        # Messaging::Queue.new(Api.config.CLONE_QUEUE_URL, Api.config)
        #   .send(Representer::Paper.new(paper).to_json)
      end

      def paper_in_database(input)
        Repository::For.klass(Entity::Paper)
          .find_paper_content(input[:id])
      end
    end
  end
end
