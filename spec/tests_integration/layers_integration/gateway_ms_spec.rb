# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'

describe 'Test microsoft academic search library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_ms
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Paper information' do
    it 'HAPPY: should provide list of papers with correct attributes' do
      papers = RefEm::MSPaper::PaperMapper
        .new(MS_TOKEN).find_papers_by_keywords(KEYWORDS, SEARCH_TYPE)
      first_paper = papers[0]
      papers.size.must_equal 10
      _(first_paper.origin_id).must_equal CORRECT['Id']
      _(first_paper.year).must_equal CORRECT['Year']
      _(first_paper.date).must_equal CORRECT['Date']
      _(first_paper.doi).must_equal CORRECT['DOI']
    end

    it 'HAPPY: should finds a papers' do
      paper = RefEm::MSPaper::PaperMapper
        .new(MS_TOKEN).find_paper(ID)
      paper.size.must_equal 1
    end

    it 'BAD: should raise exception when unautorized' do
      proc do
        RefEm::MSPaper::PaperMapper
          .new('NO_TOKEN')
          .find_papers_by_keywords(KEYWORDS, SEARCH_TYPE)
      end.must_raise RefEm::MSPaper::Api::Response::Unauthorized
    end

    it 'BAD: should raise exception when not find a paper' do
      proc do
        RefEm::MSPaper::PaperMapper
          .new(MS_TOKEN).find_paper('we cannot find a paper')
      end.must_raise RefEm::MSPaper::Api::Response::BadRequest
    end
  end
end
