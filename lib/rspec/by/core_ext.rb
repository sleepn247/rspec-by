require "rspec/core"
require "rspec/core/formatters/documentation_formatter"

# monkey patching rspec
module RSpec::Core
  class Reporter
    if defined?(NOTIFICATIONS)
      NOTIFICATIONS.push("by_started", "by_finished")
    end

    def by_started(message)
      notify :by_started, message
    end

    def by_ended(message = '')
      notify :by_ended, message
    end
  end

  unless defined?(Reporter::NOTIFICATIONS)
    class Formatters::DocumentationFormatter
      def by_started(message)
      end
      def by_ended(message = '')
      end
    end
  end

  class ExampleGroup
    def by message, level=0
      pending(message) unless block_given?
      begin
        @by_reporter.by_started(message)
        yield
      ensure
        @by_reporter.by_ended
      end
    end

    alias and_by by
  end

  class Example
    private
    
    alias :start_without_reporter :start

    def start(reporter)
      start_without_reporter(reporter)
      @example_group_instance.instance_variable_set(:@by_reporter, reporter)
    end
  end
end
