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
end