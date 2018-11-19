# frozen_string_literal: false

require_relative 'helpers/spec_helper.rb'
require_relative 'helpers/vcr_helper.rb'

describe 'Tests Semantic Scholar API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_ss
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Citation information' do
    it 'HAPPY: should provide correct citation attributes' do
      citations =
        RefEm::MSPaper::CitationMapper
          .new
          .find_data_by(DOI)
      citations.size.must_be :>=, 0
      first_citation = citations[0]
      puts "TITLE:#{first_citation.title}"
      _(first_citation.title).must_equal CORRECT['title']
      # _(first_citation.author).must_equal CORRECT['citationVelocity']
      # _(first_citation.date).must_equal CORRECT['Date']
      # _(first_citation.doi).must_equal CORRECT['DOI']
      # citations.map { |citation|
      #   puts citation
      #   puts citation.author
      #   puts citation.title
      # }
    end
  
#       _(paper.title).must_equal SS_CORRECT['title']
#       _(paper.authors).must_equal SS_CORRECT['authors']
# #      _(paper.citation_velocity).must_equal SS_CORRECT['citationVelocity']
#       _(paper.citation_dois)[2].must_equal SS_CORRECT['citation_dois'][2]
#       _(paper.citation_titles)[2].must_equal SS_CORRECT['citation_titles'][2]
#       _(paper.influential_citation_count).must_equal SS_CORRECT['influential_citation_count']
#       _(paper.venue).must_equal SS_CORRECT['venue']
#       _(paper.focus_doi).must_equal SS_CORRECT['focus_doi']
#    end

    # it 'BAD: should raise exception on incorrect project' do
    #   proc do
    #     RefEm::MSPaper::CitationMapper
    #       .new
    #       .find_data_by('foobar')
    #   end.must_raise RefEm::MSPaper::SSApi::Response::NotFound
    # end
  end
end
