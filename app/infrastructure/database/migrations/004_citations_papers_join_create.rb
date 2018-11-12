# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:citations_papers) do
      primary_key [:paper_id, :citation_id]
      foreign_key :paper_id, :papers
      foreign_key :citation_id, :citations

      index [:paper_id, :citation_id]
    end
  end
end
