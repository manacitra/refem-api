# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:citations) do
      primary_key :id
      foreign_key :paper_doi, :papers

      String  :doi
      String  :citation_doi
      Integer :citation_velocity
      String  :citation_titles
      Integer :influential_citation_count
      String  :venue

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
