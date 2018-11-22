# frozen_string_literal: true

require 'roda'
require 'econfig'

module RefEm
  # Environment specific configuration
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    use Rack::Session::Cookie, secret: config.SESSION_SECRET

    configure :development, :test do
      require 'pry'

      # Allows running <reload!> in pry to restart entire app
      def self.reload
        exec 'pry -r ./init.rb'
      end
    end

    configure :development, :test, :app_test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    end

    configure :app_test do
      require_relative '../spec/helpers/vcr_helper.rb'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_ms(recording: :none)
    end

    configure :production do
      ENV['DATABASE_URL'] = 'postgres://bpmfdmllhklqln:ad1a36f73023f80b5a370dd03bb2c1377c22194bc0a7ce35ab7f7074da21af01@ec2-50-19-249-121.compute-1.amazonaws.com:5432/d2lfq47819730n'
      # Use deployment platform's DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end
  end
end
