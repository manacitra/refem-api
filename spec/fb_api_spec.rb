require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/fb_api.rb'

describe 'Test FacebookPlaces library' do
  KEYWORDS = 'sea'.freeze
  LONGITUDE = '24.7943758'.freeze
  LATITUDE = '120.9715205'.freeze
  DISTANCE = '10000'.freeze

  CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
  FB_TOKEN = CONFIG['FB_TOKEN']

  CORRECT = YAML.safe_load(File.read('spec/fixtures/fb_results.yml'))
  ERROR = {}

  describe 'Place check-in information' do
    it 'HAPPY: should provide correct facebook attributes' do
      place = FacebookPlaces::FacebookAPI.new(FB_TOKEN).place_checkin(KEYWORDS, LONGITUDE, LATITUDE, DISTANCE)
      _(place.place_checkins[0]).must_equal CORRECT['checkins']
    end

    it 'SAD: should have no data on incorrect keywords' do
      proc do
        place = FacebookPlaces::FacebookAPI.new(FB_TOKEN).place_checkin('error', LONGITUDE, LATITUDE, DISTANCE)
        _(place.place_checkins).must_raise FacebookPlaces::FacebookAPI::Errors::Nilclass
      end
    end

    it 'SAD: should raise exception when unautorized' do
      proc do
        FacebookPlaces::FacebookAPI.new('NO_TOKEN').place_checkin(KEYWORDS, LONGITUDE, LATITUDE, DISTANCE)
      end.must_raise FacebookPlaces::FacebookAPI::Errors::Unauthorized
    end
  end
end