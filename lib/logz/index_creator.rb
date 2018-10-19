# frozen_string_literal: true

require "elasticsearch"

require_relative "./progress_spinner"

module Logz
  class IndexCreator
    include ProgressSpinner

    def initialize(client: Elasticsearch::Client.new)
      self.client = client
    end

    DOCUMENT_MAPPINGS = {
      properties: {
        params: {
          type: :nested,
          properties: {
            start: { type: :keyword },
            end: { type: :keyword },
          }
        }
      }
    }

    def create(index)
      return if client.indices.exists?(index: index)

      show_progress "Creating index '#{index}'" do
        client.indices.create index: index,
                              body: {
                                mappings: {
                                  document: DOCUMENT_MAPPINGS
                                }
                              }
      end
    end

    private

    attr_accessor :client
  end
end
