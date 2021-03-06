# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

describe 'ShowPaperList Service Integration Test' do
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

    # WHEN: the service is called with the request to show paper list
    paper_list = RefEm::Service::ShowPaperList.new.call(keyword: KEYWORDS, searchType: SEARCH_TYPE)

    # THEN: the result should report success
    _(paper_list.success?).must_equal true

    # ..and give the same information result as paper search
    first_retrieved = paper_list.value!.message[:papers][0]
    first_retrieved.must_equal first_paper_result
  end

  it 'BAD: should gracefully fail for invalid paper keyword' do
    # GIVEN: invalid keyword paper search requested:
    BAD_KEYWORD = '1nternet'

    # WHEN: the service is called to show paper list
    paper_list = RefEm::Service::ShowPaperList.new.call(keyword: BAD_KEYWORD, searchType: SEARCH_TYPE)

    # THEN: the service should report failure with an error message
    (paper_list.success?).must_equal false
    puts(paper_list.failure.message.downcase.to_s)
    (paper_list.failure.message.downcase.to_s).must_include 'keyword'
  end

  it 'BAD: should gracefully fail for invalid paper search type' do
    # GIVEN: invalid paper search type requested:
    BAD_SEARCH_TYPE = 'venue'

    # WHEN: the service is called to show paper list
    paper_list = RefEm::Service::ShowPaperList.new.call(keyword: KEYWORDS, searchType: BAD_SEARCH_TYPE)

    # THEN: the service should report failure with an error message
    paper_list.success?.must_equal false
    puts(paper_list.failure.message.downcase.to_s)
    (paper_list.failure.message.downcase.to_s).must_include 'search type'
  end

  it 'SAD: should gracefully fail for unavailable information from API' do
    # GIVEN: valid paper search type requested:
    SAD_KEYWORD = 'social'

    # WHEN: the service is called to show paper list
    paper_list = RefEm::Service::ShowPaperList.new.call(keyword: SAD_KEYWORD, searchType: SEARCH_TYPE)

    # THEN: the service should report failure with an error message
    paper_list.success?.must_equal false
    puts(paper_list.failure.message.downcase.to_s)
    _(paper_list.failure.message.downcase.to_s).must_include 'could not find'
  end
end
# codeship