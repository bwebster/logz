# frozen_string_literal: true

require "tty-spinner"

module Logz
  module ProgressSpinner
    def show_progress(msg)
      s = TTY::Spinner.new("#{msg} [:spinner]")
      s.run do
        if yield
          s.success "(successful)"
        else
          s.error "(error)"
        end
      end
    end
  end
end
