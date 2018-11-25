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
        .paper_data(DOI)
      paper['title'].must_equal SS_CORRECT['title']
      paper['authors'][0]['name'].must_equal SS_CORRECT['authors'][0]
      paper['venue'].must_equal SS_CORRECT['venue']
    end
  end

  describe 'Citation information' do
    it 'HAPPY: should provide correct citation attributes' do
      citations =
        RefEm::MSPaper::CitationMapper
          .new
          .find_data_by(DOI)
      citations.size.must_be :>=, 0
      first_citation = citations[0]
      _(first_citation.title).must_equal SS_CORRECT['citation_titles'][0]
      _(first_citation.author.split(';')[0]) \
        .must_equal (SS_CORRECT['citations'][0]['authors'][0]['name'])
      _(first_citation.year).must_equal (SS_CORRECT['citations'][0]['year'])
      _(first_citation.venue).must_equal (SS_CORRECT['citations'][0]['venue'])
    end

    it 'SAD: should return nil if doi not registered in SS' do
      expect(RefEm::MSPaper::CitationMapper
        .new
        .find_data_by('foobar')).must_equal nil
    end
  end
end
