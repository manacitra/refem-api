# frozen_string_literal: true

module CitRef
  # Infrastructure to fetch while yielding progress
  module FetchMonitor
    FETCH_PROGRESS = {
      'STARTED'   => 15,
      'FINISHED'  => 100
    }.freeze

    def self.starting_percent
      FETCH_PROGRESS['STARTED'].to_s
    end

    def self.finished_percent
      FETCH_PROGRESS['FINISHED'].to_s
    end

    def self.progress(line)
      FETCH_PROGRESS[first_word_of(line)].to_s
    end

    def self.percent(stage)
      FETCH_PROGRESS[stage].to_s
    end

    def self.first_word_of(line)
      line.match(/^[A-Za-z]+/).to_s
    end
  end
end
