# frozen_string_literal: true

require 'dry/transaction'
require 'json'
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
        # if paper_id already store in the database, get the result
        input[:paper_id] = input[:requested].id
        if (paper = paper_in_database(input))
          input[:local_paper] = paper
        else
          Messaging::Queue.new(Api.config.CIT_REF_QUEUE_URL, Api.config)
           .send(paper_request_json(input))

           redis = Redis.new(url: RefEm::Api.config.REDISCLOUD_URL)
           puts "request id: #{input[:request_id]}"
           puts "paper id: #{input[:paper_id]}"
           input[:remote_paper] = redis.get(input[:paper_id])
           puts "paper from redis: #{input[:remote_paper]}"
        end

        return Success(input) unless input[:local_paper].nil?
        return Success(input) unless input[:remote_paper].nil?
        
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
          paper_from_json = JSON.parse(input[:remote_paper]).to_hash
          paper_from_json = paper_from_json.merge(id: nil)
          paper_from_json = paper_from_json.map { |k, v| [k.to_sym, v] }.to_h
          paper_from_json[:references] = paper_from_json[:references].map { |ref|
            ref.map { |k, v| [k.to_sym, v] }.to_h
          }
          paper_from_json[:citations] = paper_from_json[:citations].map { |cit|
            cit.map { |k, v| [k.to_sym, v] }.to_h
          }
          paper = MSPaper::PaperJsonMapper.new(paper_from_json)
            .build_entity
          # puts "paper: #{paper_from_json}"
          # paper = Entity::Paper.new(paper_from_json)
          
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
        Messaging::Queue.new(Api.config.CIT_REF_QUEUE_URL, Api.config)
          .send(paper_request_json(input))
      end

      def paper_in_database(input)
        Repository::For.klass(Entity::Paper)
          .find_paper_content(input[:paper_id])
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
