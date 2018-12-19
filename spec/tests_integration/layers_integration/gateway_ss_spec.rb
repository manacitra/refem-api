# frozen_string_literal: false

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'

describe 'Tests Semantic Scholar API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_ss
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Get the correct paper info' do
    it 'Happy: should provide the correct paper information by DOI' do
      paper = RefEm::MSPaper::SSApi
        .new
        .paper_data(PAPER_DOI)
      paper['title'].must_equal PAPER_TITLE_
      paper['year'].must_equal 2003
    end
  end

  describe 'Citation information' do
    it 'HAPPY: should provide correct citation attributes' do
      citations =
        RefEm::MSPaper::CitationMapper
          .new
          .find_data_by(PAPER_DOI)
          
      citations.size.must_be :>=, 0
    end

    it 'SAD: should return nil if doi not registered in SS' do
      expect(RefEm::MSPaper::CitationMapper
        .new
        .find_data_by('foobar')).must_equal nil
    end
  end
end
