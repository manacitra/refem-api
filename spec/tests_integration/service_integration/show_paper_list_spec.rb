# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

describe 'ShowPaperContent Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_ms(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should be able to get valid input' do
    # GIVEN: a valid keyword paper search requested:
    first_paper_result = RefEm::MSPaper::PaperMapper
      .new(MS_TOKEN).find_papers_by_keywords(KEYWORDS, SEARCH_TYPE)[0]
    search_request = RefEm::Forms::Keyword.call(keyword: KEYWORDS, searchType: SEARCH_TYPE)

    # WHEN: the service is called with the request form object
    paper_list = RefEm::Service::ShowPaperList.new.call(search_request)

    # THEN: the result should report success
    _(paper_list.success?).must_equal true

    # ..and give the same information result as paper search
    first_retrieved = paper_list.value![:papers][0]
    first_retrieved.must_equal first_paper_result
  end

  it 'BAD: should gracefully fail for invalid paper keyword' do
    # GIVEN: invalid keyword paper search requested:
    BAD_KEYWORD = '1nternet'
    search_request = RefEm::Forms::Keyword.call(keyword: BAD_KEYWORD, searchType: SEARCH_TYPE)

    # WHEN: the service is called with the request form object
    paper_list = RefEm::Service::ShowPaperList.new.call(search_request)

    # THEN: the service should report failure with an error message
    (paper_list.success?).must_equal false
    (paper_list.failure.downcase).must_include 'invalid keyword'
  end

  it 'BAD: should gracefully fail for invalid paper search type' do
    # GIVEN: invalid paper search type requested:
    BAD_SEARCH_TYPE = 'venue'
    search_request = RefEm::Forms::Keyword.call(keyword: KEYWORDS, searchType: BAD_SEARCH_TYPE)

    # WHEN: the service is called with the request form object
    paper_list = RefEm::Service::ShowPaperList.new.call(search_request)

    # THEN: the service should report failure with an error message
    (paper_list.success?).must_equal false
    (paper_list.failure.downcase).must_include 'invalid search type'
  end

  it 'SAD: should gracefully fail for unavailable information from API' do
    # GIVEN: valid paper search type requested:
    SAD_KEYWORD = 'social'
    search_request = RefEm::Forms::Keyword.call(keyword: SAD_KEYWORD, searchType: SEARCH_TYPE)

    # WHEN: the service is called with the request form object
    paper_list = RefEm::Service::ShowPaperList.new.call(search_request)

    # THEN: the service should report failure with an error message
    (paper_list.success?).must_equal false
    (paper_list.failure.downcase).must_include 'could not find'
  end
end
