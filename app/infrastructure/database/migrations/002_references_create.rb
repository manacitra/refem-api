# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:referencess) do
      primary_key :id

      Integer   :origin_id
      String    :title,               null: false
      String    :author
      Integer   :year
      String    :date
      String    :field
      String    :references,          null: true
      String    :doi,                 null: true
      String    :venue_full,          null: true
      Integer   :volume,              null: true
      String    :journal_name,        null: true
      Integer   :citation_count,      null: true
      String    :reference_content,   null: true
      String    :link,                null: true

      # attribute :references,  Strict::Array.member(Paper).optional
    end
  end
end
