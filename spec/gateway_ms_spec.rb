# frozen_string_literal: false

require_relative 'spec_helper.rb'
require_relative 'helpers/vcr_helper.rb'

describe 'Test microsoft academic search library' do
  before do
<<<<<<< HEAD
    VcrHelper.configure_vcr_for_ss
=======
    VcrHelper.configure_vcr_for_ms
>>>>>>> 6132d80d6cd864a4363a7328a27d264fa65ce1fb
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Paper information' do
<<<<<<< HEAD
    it 'HAPPY: should provide correct paper attributes' do
=======
    it "HAPPY: should provide correct paper attributes" do
>>>>>>> 6132d80d6cd864a4363a7328a27d264fa65ce1fb
      paper = RefEm::MSPaper::PaperMapper
              .new(MS_TOKEN)
              .find(KEYWORDS, COUNT)
      paper.size.must_equal 10
      first_paper = paper[0]
      _(first_paper.id).must_equal CORRECT['Id']
      _(first_paper.year).must_equal CORRECT['Year']
      _(first_paper.date).must_equal CORRECT['Date']
      _(first_paper.doi).must_equal CORRECT['DOI']
    end

    it 'SAD: should have error on incorrect counts' do
      proc do
        RefEm::MSPaper::PaperMapper
          .new(MS_TOKEN)
          .find(KEYWORDS, '-5')
      end.must_raise RefEm::MSPaper::Api::Response::BadRequest
    end

    it 'SAD: should raise exception when unautorized' do
      proc do
        RefEm::MSPaper::PaperMapper
          .new('NO_TOKEN')
          .find(KEYWORDS, COUNT)
      end.must_raise RefEm::MSPaper::Api::Response::Unauthorized
    end
  end
end

