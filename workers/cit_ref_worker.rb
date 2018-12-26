# frozen_string_literal: true

require_relative '../init.rb'

require 'econfig'
require 'shoryuken'
require 'json'
require 'redis'

# Shoryuken worker class to clone repos in parallel
class CitRefWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CIT_REF_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    paper_id = JSON.parse(request)
    paper = RefEm::MSPaper::PaperMapper.new(RefEm::Api.config.MS_TOKEN).find_paper(paper_id)
    paper_to_json = RefEm::Representer::Paper.new(paper[0]).to_json
    request_id = [paper_id, Time.now.to_f].hash
    redis = Redis.new(url: RefEm::Api.config.REDISCLOUD_URL)
    redis.set(request_id, paper_to_json)

    content = redis.get("#{request_id}")
    puts "redis content: #{content}"

  rescue RefEm::MSPaper::Errors::CannotCacheLocalPaper
    # only catch errors you absolutely expect!
    puts 'CACHE EXISTS -- ignoring request'
  end
end