# frozen_string_literal: true

require 'roda'
require 'yaml'

module RefEm
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    MS_TOKEN = CONFIG['MS_TOKEN']
  end
end
