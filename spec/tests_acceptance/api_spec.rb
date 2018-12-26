# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'
require_relative '../helpers/vcr_helper.rb'
require_relative '../helpers/database_helper.rb'
require 'rack/test'

def app
  RefEm::Api
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_ms
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Show paper list route' do
    it 'should be able to show paper list' do
      RefEm::Service::ShowPaperList.new.call(
        keyword: KEYWORDS, searchType: SEARCH_TYPE
      )

      get "/api/v1/paper/#{SEARCH_TYPE}/#{KEYWORDS}"
      _(last_response.status).must_equal 200
      papersList = JSON.parse last_response.body
      _(papersList['papers'].count).must_equal 10
      _(papersList['papers'][0]['origin_id']).must_equal 2118428193
      _(papersList['papers'][0]['title']).must_equal "chord a scalable peer to peer lookup protocol for internet applications"
      _(papersList['papers'][0]['year']).must_equal 2003
      _(papersList['papers'][0]['doi']).must_equal "10.1109/TNET.2002.808407"
    end

    it 'should be report error for an invalid keyword' do
      RefEm::Service::ShowPaperList.new.call(
        keyword: 'woeihewif', searchType: SEARCH_TYPE
      )

      get "/api/v1/paper/#{SEARCH_TYPE}/woeihewif"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end

    it 'should be report error for an invalid searchtype and keyword' do
      RefEm::Service::ShowPaperList.new.call(
        keyword: 'woeihewif', searchType: 'eoijosfsf'
      )

      get "/api/v1/paper/eoijosfsf/woeihewif"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Show paper content route' do
    it 'should be able to show paper content' do
      RefEm::Service::ShowPaperContent.new.call(id: ID)

      get "/api/v1/paper/#{ID}"
      _(last_response.status).must_equal 200
      main_paper = JSON.parse last_response.body
      _(main_paper['paper']['origin_id']).must_equal 2118428193
      _(main_paper['paper']['title']).must_equal "chord a scalable peer to peer lookup protocol for internet applications"
      _(main_paper['paper']['year']).must_equal 2003
      _(main_paper['paper']['doi']).must_equal "10.1109/TNET.2002.808407"

      _(main_paper['paper']['citations'].count).must_equal 5
      #_(main_paper['paper']['citations'][0]['title']).must_equal "Introducing artificial evolution into peer-to-peer networks with the distributed remodeling framework"
      #_(main_paper['paper']['citations'][0]['links'][0]['href']).must_equal "https://api.semanticscholar.org/818e72a3a379ff0211a466610e53e7e1943358ae"

      _(main_paper['paper']['references'].count).must_equal 5
      _(main_paper['paper']['references'][0]['title']).must_equal "chord a scalable peer to peer lookup service for internet applications"
      _(main_paper['paper']['references'][0]['link']).must_equal "https://academic.microsoft.com/#/detail/2167898414"
    end

    it 'should be report error for an invalid paper Id' do
      RefEm::Service::ShowPaperContent.new.call(id: 2938294722342)

      get "/api/v1/paper/2938294722342"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

end