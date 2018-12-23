# frozen_string_literal: true

require 'aws-sdk-sqs'

module RefEm
  module Messaging
    ## Queue wrapper for AWS SQS
    # Requires: AWS credentials loaded in ENV or through config file
    class Queue
      IDLE_TIMEOUT = 120 # seconds
      
      def initialize(queue_url, config)
        @queue_url = queue_url
        @sqs = Aws::SQS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: 'ap-northeast-1'
        )
        @queue = Aws::SQS::Queue.new(url: queue_url, client: @sqs)
      end
      
      ## Sends message to queue
      # Usage:
      #   q = Messaging::Queue.new(Api.config.CLONE_QUEUE_URL)
      #   q.send({data: "hello"}.to_json)
      def send(message)
        @queue.send_message(message_body: message)
      end
      
      ## Polls queue, yielding each messge
      # Usage:
      #   q = Messaging::Queue.new(Api.config.CLONE_QUEUE_URL)
      #   q.poll { |msg| print msg.body.to_s }
      def poll
        poller = Aws::SQS::QueuePoller.new(@queue_url, client: @sqs)
        poller.poll(idle_timeout: IDLE_TIMEOUT) do |msg|
          yield msg.body if block_given?
          puts "mmm: #{JSON.parse(msg.body)}"
          p = JSON.parse(msg.body)
          puts "id: #{p}"
          paper = MSPaper::PaperMapper.new(Api.config.MS_TOKEN).find_paper(p)
          puts "paper class: #{paper[0].title}"
          paper
        end
      end
    end
  end
end
