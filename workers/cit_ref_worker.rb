# frozen_string_literal: true

# require_relative '../app/domain/init.rb'
# require_relative '../app/application/values/init.rb'
# require_relative '../app/infrastructure/gateways/init.rb'
# require_relative '../app/presentation/representers/init.rb'
require_relative '../init.rb'

require_relative 'progress_reporter.rb'
require_relative 'paper_fetch.rb'


require 'econfig'
require 'shoryuken'
require 'redis'

module CitRef
  # Shoryuken worker class to get paper from api and send progress report in parallel
  class Worker
    extend Econfig::Shortcut
    Econfig.env = ENV['RACK_ENV'] || 'development'
    Econfig.root = File.expand_path('..', File.dirname(__FILE__))

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 10 }
    shoryuken_options queue: config.CIT_REF_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      # use setup_job to get required info for worker
      paper_id, request_id, reporter = setup_job(request)
      puts "--got paper_id from setup job"

      # start publishing progress
      reporter.publish(FetchMonitor.starting_percent)
      puts "start publishing"

      # find paper content object and parse it into json
      reporter.publish(FetchMonitor.fetch_percent)
      puts "-----------before concurrency"
      paper = RefEm::MSPaper::PaperMapper.new(Worker.config.MS_TOKEN)
        .find_paper(paper_id)
      puts "---------------after concurrency"

      paper_to_json = RefEm::Representer::PaperJSON.new(paper[0]).to_json

      # save serialized paper into redis
      redis = Redis.new(url: RefEm::Api.config.REDISCLOUD_URL)
      redis.set(paper_id, paper_to_json)
      puts "----------------paper saved to redis"

      # # content = redis.get(request_id.to_s)
      # # puts "redis content: #{content}"
      reporter.publish(FetchMonitor.finished_percent)
      puts "published finish"
    rescue RefEm::MSPaper::Errors::CannotCacheLocalPaper
      # only catch errors you absolutely expect!
      puts 'CACHE EXISTS -- ignoring request'
    end

    private

    def setup_job(request)
      paper_request = RefEm::Representer::PaperRequest
        .new(OpenStruct.new).from_json(request)

      [paper_request.paper_id,
       paper_request.request_id,
       ProgressReporter.new(Worker.config, paper_request.request_id)]
    end

    def each_second(seconds)
      seconds.times do
        sleep(1)
        yield if block_given?
      end
    end
  end
end
