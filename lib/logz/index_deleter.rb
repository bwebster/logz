# frozen_string_literal: true

require "elasticsearch"

require_relative "./progress_spinner"

module Logz
  class IndexDeleter
    include ProgressSpinner

    def initialize(client: Elasticsearch::Client.new)
      self.client = client
    end

    def delete(index)
      return unless client.indices.exists?(index: index)

      show_progress "Deleting index '#{index}'" do
        client.indices.delete index: index
      end
    end

    private

    attr_accessor :client
  end
end
