# frozen_string_literal: true

require "elasticsearch"

require_relative "./progress_spinner"

module Logz
  class IndexCreator
    include ProgressSpinner

    def initialize(client: Elasticsearch::Client.new)
      self.client = client
    end

    def create(index)
      return if client.indices.exists?(index: index)

      show_progress "Creating index '#{index}'" do
        client.indices.create index: index,
                              body: {
                                mappings: {
                                  document: {
                                    properties: {
                                      params: {
                                        type: :nested
                                      }
                                    }
                                  }
                                }
                              }
      end
    end

    private

    attr_accessor :client
  end
end
