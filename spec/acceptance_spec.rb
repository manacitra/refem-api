# frozen_string_literal: true

require_relative 'helpers/spec_helper.rb'
require_relative 'helpers/database_helper.rb'
require_relative 'helpers/vcr_helper.rb'
require 'headless'
require 'watir'

describe 'Acceptance Tests' do
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    @headless = Headless.new
    @headless.start
    @browser = Watir::Browser.new :chrome
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Homepage' do
    describe 'Visit Home page' do
      it '(HAPPY) should not see anything other than defaut homepage' do
        # GIVEN: user is on the home page
        @browser.goto homepage

         # THEN: user should see basic headers, no projects and a welcome message
        _(@browser.h1(id: 'main_header').text).must_equal 'RefEm'
        _(@browser.text_field(id: 'paper_query_input').present?).must_equal true
        _(@browser.button(id: 'paper_search-submit').present?).must_equal true
      end
    end
    describe 'Search papers based on keyword' do
      it '(HAPPY) should be able to search papers' do
        # GIVEN: user is on the home page
        @browser.goto homepage
        # WHEN: they add enter a keyword and submit
        good_keyword = KEYWORDS
        @browser.text_field(id: 'paper_query_input').set(good_keyword)
        @browser.button(id: 'paper_search-submit').click
        # THEN: they should find themselves a list of papers
        @browser.url.include? 'find_paper'
      end
      it '(BAD) should not be input invalid keywords' do
        # GIVEN: user is on the home page
        @browser.goto homepage
        # WHEN: they input a bad/invalid keyword
        bad_keyword = 'foobar'
        @browser.text_field(id: 'paper_query_input').set(bad_keyword)
        @browser.button(id: 'paper_search-submit').click
        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'not found'
      end
      it '(BAD) should not receive nil keywords' do
        # GIVEN: user is on the home page
        @browser.goto homepage
        # WHEN: they input a bad/invalid keyword
        nil_keyword = ''
        @browser.text_field(id: 'paper_query_input').set(nil_keyword)
        @browser.button(id: 'paper_search-submit').click
        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'please enter'
      end
      it "(SAD) should be able to search, but API can't serve it" do
        # GIVEN: user is on the home page
        @browser.goto homepage
        # WHEN: they try
        sad_keyword = 'social'
        @browser.text_field(id: 'paper_query_input').set(sad_keyword)
        @browser.button(id: 'paper_search-submit').click
        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'trouble'
      end
    end
  end
  describe 'Find Paper List Page' do
    it '(HAPPY) should see list of 10 papers related to keyword' do
      # GIVEN: user input a valid keyword
      good_keyword = KEYWORDS
      papers = RefEm::MSPaper::PaperMapper
        .new(MS_TOKEN)
        .find_papers_by_keywords(good_keyword)
      @browser.goto homepage
      @browser.text_field(id: 'paper_query_input').set(good_keyword)
      # WHEN: user submit the keyword
      @browser.button(id: 'paper_search-submit').click
      # THEN: they should see the related paper list
      related_paper_titles = @browser.span(class: 'paper_title').select do |a|
        a(class: 'paper_detail').present?
      end
      related_paper_titles.must_equal 10
      related_paper_authors = @browser.span(class: 'paper_author').must_equal 10
      related_paper_years = @browser.span(class: 'paper_year').must_equal 10
      related_paper_dois = @browser.span(class: 'paper_doi').must_equal 10
    end
  end
  describe 'Display Paper Content (References and Citations)' do
    it '(HAPPY) should get list of refences' do
      # references = 
    end
    it '(HAPPY) should get list of citations' do
      # citations = 
    end
  end
end
