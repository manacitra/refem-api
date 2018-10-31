# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'pry'

require_relative '../init.rb'

KEYWORDS = 'internet'.freeze
COUNT = '10'.freeze
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
MS_TOKEN = CONFIG['MS_TOKEN']
CORRECT = YAML.safe_load(File.read('spec/fixtures/ms_results.yml'))
ERROR = {}

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTES_FILE = 'ms_api'.freeze
