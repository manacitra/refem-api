# frozen_string_literal: true

require 'roda'
require 'econfig'

module RefEm
  # Configuration for the App
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      require 'pry'

      # Allows running <reload!> in pry to restart entire app
      def self.reload
        exec 'pry -r ./init.rb'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    end

    configure :production do
      ENV['DATABASE_URL'] = 'postgres://aggvsomldqpibf:b2eb490691b82d0ff1eb4f414b38a8df4d4824cd57e5fc071715d53ae48e7e31@ec2-50-19-249-121.compute-1.amazonaws.com:5432/dfn89na53ubt5t'
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
