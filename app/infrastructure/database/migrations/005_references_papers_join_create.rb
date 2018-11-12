# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:references_papers) do
      primary_key [:paper_id, :reference_id]
      foreign_key :paper_id, :papers
      foreign_key :reference_id, :references

      index [:paper_id, :reference_id]
    end
  end
end
