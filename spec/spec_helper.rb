# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../init.rb'

KEYWORDS = 'internet'.freeze
COUNT = '1'.freeze
CONFIG = YAML.safe_load(File.read('../config/secrets.yml'))
MS_TOKEN = CONFIG['MS_TOKEN']
CORRECT = YAML.safe_load(File.read('fixtures/ms_results.yml'))
ERROR = {}

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTES_FILE = 'ms_api'.freeze
