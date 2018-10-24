require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/ms_api.rb'

describe 'Test microsoft academic search library' do
  KEYWORDS = 'internet'.freeze
  COUNT = '1'.freeze

  CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
  MS_TOKEN = CONFIG['MS_TOKEN']

  CORRECT = YAML.safe_load(File.read('spec/fixtures/ms_results.yml'))
  ERROR = {}

  describe 'Paper information' do
    it "HAPPY: should provide correct paper attributes" do
      paper = MSAcademic::MicrosoftAPI.new(MS_TOKEN).paper(KEYWORDS, COUNT)
      _(paper.paper_id).must_equal CORRECT['Id']
      _(paper.paper_year).must_equal CORRECT['Year']
      _(paper.paper_date).must_equal CORRECT['Date']
      _(paper.paper_doi).must_equal CORRECT['DOI']
    end

    it 'SAD: should have error on incorrect counts' do
      proc do
        MSAcademic::MicrosoftAPI.new(MS_TOKEN).paper(KEYWORDS, '-5')
      end.must_raise MSAcademic::MicrosoftAPI::Response::BadRequest
    end

    it 'SAD: should raise exception when unautorized' do
      proc do
        MSAcademic::MicrosoftAPI.new('NO_TOKEN').paper(KEYWORDS, COUNT)
      end.must_raise MSAcademic::MicrosoftAPI::Response::Unauthorized
    end
  end
end