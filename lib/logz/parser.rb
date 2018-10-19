# frozen_string_literal: true

require "elasticsearch"
require "active_support/time"
require "addressable/uri"

require_relative "./progress_spinner"

module Logz
  class Parser
    include ProgressSpinner

    def initialize(client: Elasticsearch::Client.new)
      self.client = client
    end

    def run(index)
      token = ENV.fetch("PAPERTRAIL_API_TOKEN")

      start_at = min_timestamp(client, :generated_at)
      end_at = 2.weeks.ago

      date_time = DateTime.new(start_at.year, start_at.month, start_at.day, start_at.hour, 0, 0, start_at.zone)

      while date_time >= end_at
        begin
          date = date_time.strftime("%Y-%m-%d-%H")
          show_progress "Downloading #{date}.tsv.gz" do
            `curl -s --no-include -o archive.tsv.gz -L -H "X-Papertrail-Token: #{token}" https://papertrailapp.com/api/v1/archives/#{date}/download`
            `gunzip archive.tsv.gz`
          end

          show_progress "Grepping for matches" do
            `cat archive.tsv | grep -- "-prodc" | grep "status=503" > 503.tsv`
          end

          line_count = `wc -l 503.tsv`.strip.split(' ')[0].to_i
          puts "Found #{line_count} matches"

          show_progress "Indexing" do
            File.open("./503.tsv").each do |line|
              client.index index: index, type: :document, body: build_document(line)
            end
          end
        ensure
          `rm -f archive.tsv.gz`
          `rm -f archive.tsv`
          `rm -f 503.tsv`
        end

        date_time = date_time - 1.hour
      end
    end

    private

    def build_document(line)
      id, generated_at, received_at, source_id, source_name, source_ip,
        facility_name, severity_name, program, message = line.split("\t")

      code = (message =~ /code=([^ ]+)/ && $1)
      method = (message =~ /method=([^ ]+)/ && $1)
      path_and_params = (message =~ /path="([^ ]+)"/ && $1)
      host = (message =~ /host=([^ ]+)/ && $1)
      request_id = (message =~ /request_id=([^ ]+)/ && $1)
      service = (message =~ /service=([^ ]+)ms/ && $1)
      service = Integer(service) if service # sometimes you get: service= status=503

      uri = Addressable::URI.parse(path_and_params)
      path = uri.path
      params = uri.query_values

      subdomain = if host =~ /(.*)\.kapost\.com/
                    $1
                  else
                    "unknown"
                  end

      {
        id: id,
        line: line,
        generated_at: generated_at,
        received_at: received_at,
        source_id: source_id,
        source_name: source_name,
        source_ip: source_ip,
        facility_name: facility_name,
        severity_name: severity_name,
        program: program,
        message: message,
        code: code,
        method: method,
        host: host,
        subdomain: subdomain,
        request_id: request_id,
        service: service,
        path_and_params: path_and_params,
        path: path,
        params: params
      }
    end

    attr_accessor :client

    def min_timestamp(client, field)
      response = client.search index: INDEX, type: :document, body: {
        size: 0,
        aggs: {
          min: {
            min: {
              field: field
            }
          }
        }
      }
      value = response.dig("aggregations", "min", "value_as_string") || Time.now.iso8601
      Time.parse(value)
    end
  end
end
