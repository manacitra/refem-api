# frozen_string_literal: true

folders = %w[entities mappers repositories views]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
