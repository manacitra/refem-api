# frozen_string_literal: true

require_relative 'helpers/spec_helper.rb'
require_relative 'helpers/vcr_helper.rb'
require_relative 'helpers/database_helper.rb'

describe 'Integration Tests of Github API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_ms
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store paper' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save paper to database from MS api' do
      full_paper = RefEm::MSPaper::PaperMapper
        .new(MS_TOKEN)
        .find_papers_by_keywords(KEYWORDS)
        
      find_paper = RefEm::MSPaper::PaperMapper
        .new(MS_TOKEN)
        .find_paper(ID)
      
      paper = find_paper[0]

      rebuilt = RefEm::Repository::For.entity(paper).create(paper)

      _(rebuilt.origin_id).must_equal(paper.origin_id)
      _(rebuilt.title).must_equal(paper.title)
      _(rebuilt.author).must_equal(paper.author)
      _(rebuilt.year).must_equal(paper.year)
      _(rebuilt.date).must_equal(paper.date)
      _(rebuilt.field).must_equal(paper.field)
      _(rebuilt.references.count).must_equal(paper.references.count)
      _(rebuilt.doi).must_equal(paper.doi)

      paper.references.each do |reference|
        found = rebuilt.references.find(reference) do |potential|
          potential.origin_id == reference.origin_id
        end

        _(found.origin_id).must_equal reference.origin_id
        _(found.title).must_equal reference.title
        _(found.year).must_equal reference.year
        _(found.doi).must_equal reference.doi unless reference.doi == nil
        _(found.citation_count).must_equal reference.citation_count
      end
    end
  end
end