# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require 'pry' # for degbugging

require_relative '../../init.rb'

KEYWORDS = 'internet'
ID = '2118428193'
MS_TOKEN = RefEm::App.config.MS_TOKEN
CORRECT = YAML.safe_load(File.read('spec/fixtures/ms_results.yml'))
SS_CORRECT = YAML.safe_load(File.read('spec/fixtures/ss_results.yml'))
ERROR = {}
DOI = '10.1162/089120103321337421'

def homepage
  RefEm::App.config.APP_HOST
end
