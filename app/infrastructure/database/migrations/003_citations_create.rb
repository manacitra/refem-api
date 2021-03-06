# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:citations) do
      primary_key :id
      # foreign_key :paper_doi, :papers

      String    :origin_id
      String    :title,           null: false
      String    :author
      Integer   :year,            null: true
      String    :doi
      String    :venue
      Integer   :influential_citation_count
      String    :link,            null: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
