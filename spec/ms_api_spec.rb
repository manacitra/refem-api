# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Test microsoft academic search library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<MS_TOKEN>') { MS_TOKEN }
    c.filter_sensitive_data('<MS_TOKEN_ESC>') { CGI.escape(MS_TOKEN) }
    
    before do
      VCR.insert_cassette CASSETTES_FILE,
                          record: :new_episodes,
                          match_requests_on: %i[method uri headers]
    end

    after do
      VCR.eject_cassette
    end

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
end
