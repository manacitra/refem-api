# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:refpapers_papers) do
      primary_key [:paper_id, :refpaper_id]
      foreign_key :paper_id, :papers
      foreign_key :refpaper_id, :refpapers

      index [:paper_id, :refpaper_id]
    end
  end
end
