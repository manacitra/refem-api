# frozen_string_literal: true

folders = %w[papers views]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
