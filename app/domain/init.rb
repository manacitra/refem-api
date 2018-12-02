# frozen_string_literal: true

folders = %w[papers]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
