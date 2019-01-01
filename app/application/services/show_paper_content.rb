# frozen_string_literal: true

require 'dry/transaction'
require 'redis'

module RefEm
  module Service
    # Transaction to store paper from MS API to database
    class ShowPaperContent
      include Dry::Transaction

      step :find_main_paper
      step :calculate_top_paper
      step :store_paper

      private

      NO_PAPER_ERR = 'Paper Not Found'
      PAPER_ERR = 'Could not get details for this paper'
      DB_ERR_MSG = 'Having trouble accessing the database'
      MS_ID_NOT_FOUND = 'Could not find papers by the ID'

      def find_main_paper(input)
        # if request_id already cached in redis, get the result
        redis = Redis.new(url: RefEm::Api.config.REDISCLOUD_URL)
        return Success(input) if (request = redis.get(input[:request_id].to_s))

        # else send requested paper_id and unique queue request_id info to queue
        input[:paper_id] = input[:requested].id

        Messaging::Queue.new(Api.config.CIT_REF_QUEUE_URL, Api.config)
          .send(paper_request_json)

        # send status and queue request_id to web api -> web app
        Failure(
          Value::Result.new(status: :processing,
                            message: { request_id: input[:request_id] })
        )
      rescue StandardError => error
        puts [error.inspect, error.backtrace].flatten.join("\n")
        Failure(Value::Result.new(status: :internal_error, message: PAPER_ERR))
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
        a = MSPaper::PaperMapper
          .new(Api.config.MS_TOKEN)
          .find_paper(input[:id])
        puts a
        a
      end

      def paper_in_database(input)
        Repository::For.klass(Entity::Paper)
          .find_paper_content(input[:id])
      end

      # Utility function
      # json representer for paper_id and queue request_id
      def paper_request_json(input)
        Value::PaperRequest.new(input[:paper_id], input[:request_id])
          .yield_self { |request| Representer::PaperRequest.new(request) }
          .yield_self(&:to_json)
      end
    end
  end
end
