require "rspec/core/formatters/documentation_formatter"

##
# This class formats RSpec to puts failing tests instantly with some
# nice outputting/benchmarking. Useful for longer suites.
# Known issue: when by statements are nested, the output gets muddled

module RSpec
  module By
    class Formatter < RSpec::Core::Formatters::DocumentationFormatter
      RSpec::Core::Formatters.register self,
                                   :example_failed,
                                   :example_started,
                                   :example_passed,
                                   :by_started,
                                   :by_ended

      RIGHT_MARGIN = 80

      def initialize(output)
        super(output)
        @failed_examples = []
        @by_message_length = 0
      end

      def example_started(notification)
        output.puts(
          "#{current_indentation}Example: #{notification.example.description}")
        @group_level += 1
        @example_began = @during = RSpec::Core::Time.now
      end

      def example_passed(passed)
        @group_level -= 1
        passed_msg = indent("Passed")
        end_msg = end_tm.rjust(RIGHT_MARGIN - passed_msg.length, ' ')
        output.puts RSpec::Core::Formatters::ConsoleCodes.wrap(
                      "#{passed_msg}#{end_msg}", :success)
      end

      def example_failed(failure)
        @group_level -= 1
        output.puts("#{current_indentation}Failed in #{end_tm}")
        @failed_examples << failure.example
        output.puts failure.fully_formatted(@failed_examples.size)
        output.puts
      end

      def by_started message
        res = indent message
        @by_message_length = res.length
        output.print by_output(res)
      end

      def by_ended(message)
        message += during_tm
        output.puts by_output(message.rjust(RIGHT_MARGIN - @by_message_length, ' '))
      end

      def indent message
        "#{current_indentation}#{message}"
      end

      def by_output message
        RSpec::Core::Formatters::ConsoleCodes.wrap(message, :cyan)
      end

      def during_tm
        temp = RSpec::Core::Time.now
        delta = temp - @during
        @during = temp
        format_time(delta)
      end

      def end_tm
        delta = RSpec::Core::Time.now - @example_began
        format_time(delta)
      end

      def format_time(duration)
        if duration > 60
          minutes = duration.to_i / 60
          seconds = duration - minutes * 60
          "#{minutes}m #{format_seconds(seconds)}s"
        else
          "#{format_seconds(duration)}s"
        end
      end

      def format_seconds(float, precision = nil)
        precision ||= (float < 1) ? 5 : 2
        sprintf("%.#{precision}f", float)
      end
    end
  end
end
