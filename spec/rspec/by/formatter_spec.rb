require "rspec/by/core_ext"
require "stringio"

module RSpec::By
  RSpec.describe Formatter do

    def undent(raw)
      if raw =~ /\A( +)/
        indent = $1
        raw.gsub(/^#{indent}/, '').gsub(/ +$/, '')
      else
        raw
      end
    end

    def normalize_durations(output)
      output.gsub(/(\d?m )?\d+\.\d+s/) do |dur|
        $1 == 'm' ? "nm n.nns" : "n.nnnnns"
      end
    end

    def remove_color(output)
      output.gsub(/\e\[(\d+)(;\d+)*m/, '')
    end

    def reporter
      @reporter ||= setup_reporter
    end

    def setup_reporter(*streams)
      config.add_formatter described_class, *streams
      @formatter = config.formatters.first
      @reporter = config.reporter
    end

    def config
      @configuration ||=
        begin
          config = RSpec::Core::Configuration.new
          config.output_stream = formatter_output
          config
        end
    end

    def formatter_output
      @formatter_output ||= StringIO.new
    end

    def formatter
      @formatter ||=
        begin
          setup_reporter
          @formatter
        end
    end

    it "outputs correctly" do
      group = RSpec.describe("root")
      context1 = group.describe("context 1")
      context1.example("nested example 1.1"){}
      context1.example("nested example 1.2") do
        by('knock knock') {}
        and_by("who's there?") {}
        and_by('by') {}
        and_by('by who?') {}
        and_by('by by') {}
      end

      context11 = context1.describe("context 1.1")
      context11.example("nested example 1.1.1"){}
      context11.example("nested example 1.1.2"){}

      context2 = group.describe("context 2")
      context2.example("nested example 2.1"){}
      context2.example("nested example 2.2"){}

      group.run(reporter)

      output = normalize_durations(formatter_output.string)
      output = remove_color(output)
      expect(output).to eq(normalize_durations("
root
  context 1
    Example: nested example 1.1
    Passed                                                              0.00022s
    Example: nested example 1.2
      knock knock                                                       0.00022s
      who's there?                                                      0.00022s
      by                                                                0.00022s
      by who?                                                           0.00022s
      by by                                                             0.00022s
    Passed                                                              0.00022s
    context 1.1
      Example: nested example 1.1.1
      Passed                                                            0.00022s
      Example: nested example 1.1.2
      Passed                                                            0.00022s
  context 2
    Example: nested example 2.1
    Passed                                                              0.00022s
    Example: nested example 2.2
    Passed                                                              0.00022s
"))
    end
  end
end
