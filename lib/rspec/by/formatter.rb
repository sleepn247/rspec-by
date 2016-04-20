require "rspec/core/formatters/documentation_formatter"

##
# This class formats RSpec to puts failing tests instantly with some
# nice outputting/benchmarking. Useful for longer suites.
# Known issue: when by statements are nested, the output gets muddled

module RSpec
  module By
    class Formatter < RSpec::Core::Formatters::DocumentationFormatter
      RSpec::Core::Formatters.register self,
                                   :example_group_started,
                                   :example_group_finished,
                                   :example_started,
                                   :example_passed,
                                   :example_failed,
                                   :by_started,
                                   :by_ended

      RIGHT_MARGIN = 80

      def initialize(output)
        super(output)
        @failed_examples = []
        @bullets = [Bullet.new('', true)]
      end

      def example_group_started(notification)
        bullet_start(notification.group.description)
      end

      def example_group_finished(_notification)
        @bullets.pop
      end

      def example_started(notification)
        bullet_start(notification.example.description)
      end

      def example_passed(passed)
        bullet_end(:success)
      end

      def example_failed(failure)
        @failed_examples << failure.example
        output.puts failure.fully_formatted(@failed_examples.size)
        bullet_end
      end

      def by_started message
        bullet_start(message, :cyan)
      end

      def by_ended(message)
        bullet_end(:cyan)
      end

      def indent message
        "#{current_indentation}#{message}"
      end

      def current_indentation
        '  ' * (@bullets.size - 1)
      end

      def current_bullet
        @bullets.last
      end

      def bullet_start(message, color = :white)
        unless current_bullet.nested?
          offset = RIGHT_MARGIN - current_bullet.offset
          output.print RSpec::Core::Formatters::ConsoleCodes.wrap(current_bullet.delta_t.rjust(offset, ' '), color)
          output.puts ''
          current_bullet.nest
        end
        res = indent message
        output.print RSpec::Core::Formatters::ConsoleCodes.wrap(res, color)
        @bullets.push(Bullet.new(res))
      end

      def bullet_end(color = :white)
        bullet = @bullets.pop
        if bullet.nested?
          bullet.message = ''
        end
        offset = RIGHT_MARGIN - bullet.offset
        output.puts RSpec::Core::Formatters::ConsoleCodes.wrap(bullet.delta_t.rjust(offset, ' '), color)
      end

      class Bullet
        attr_accessor :message
        def initialize(message = '', nested = false)
          @t0 = RSpec::Core::Time.now
          @nested = nested
          @message = message
        end

        def delta_t
          delta_t = RSpec::Core::Time.now - @t0
          format_time(delta_t)
        end

        def offset
          @message.size
        end

        def nest
          @nested = true
        end

        def nested?
          @nested
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

        def format_seconds(float, precision = 2)
          #precision ||= (float < 1) ? 5 : 2
          sprintf("%.#{precision}f", float)
        end
      end
    end
  end
end
