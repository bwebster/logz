# frozen_string_literal: true

require_relative "./lib/logz"

INDEX = ENV.fetch("INDEX_NAME")

desc "Delete index '#{INDEX}'"
task :delete do
  Logz::IndexDeleter.new.delete INDEX
end

desc "Create index '#{INDEX}' with proper mappings"
task :create do
  Logz::IndexCreator.new.create INDEX
end

desc "Download, parse, and index data to '#{INDEX}'"
task index: [:create] do
  Logz::Parser.new.run INDEX
end

task default: :index
