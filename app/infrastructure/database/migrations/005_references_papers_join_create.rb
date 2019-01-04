# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:referencess_papers) do
      primary_key [:paper_id, :references_id]
      foreign_key :paper_id, :papers
      foreign_key :references_id, :referencess

      index [:paper_id, :references_id]
    end
  end
end
