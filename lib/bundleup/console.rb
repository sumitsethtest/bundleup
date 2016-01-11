module Bundleup
  module Console
    ANSI_CODES = {
      :red    => 31,
      :green  => 32,
      :yellow => 33,
      :blue => 34,
      :gray   => 90
    }.freeze

    def ok(message)
      color(:green, "✔ #{message}")
    end

    def attention(message)
      color(:yellow, message)
    end

    def color(color_name, message)
      code = ANSI_CODES[color_name]
      return puts(message) if code.nil?
      puts "\e[0;#{code};49m#{message}\e[0m"
    end

    def confirm(question)
      print question.sub(/\??\z/, " [Yn]? ")
      gets =~ /^($|y)/i
    end

    def progress(message, &block)
      print "\e[90m#{message}... \e[0m"
      thread = Thread.new(&block)
      thread.join(0.5)
      %w(/ - \\ |).cycle do |char|
        break if thread.join(0.1)
        print "\r\e[90m#{message}... #{char} \e[0m"
      end
      puts "\r\e[90m#{message}... OK\e[0m"
      thread.value
    end

    # Given a two-dimensional Array of strings representing a table of data,
    # translate each row into a single string by joining the values with
    # whitespace such that all the columns are nicely aligned.
    #
    # If a block is given, map the rows through the block first. These two
    # usages are equivalent:
    #
    #   tableize(rows.map(&something))
    #   tableize(rows, &something)
    #
    # Returns a one-dimensional Array of strings, each representing a formatted
    # row of the resulting table.
    #
    def tableize(rows, &block)
      rows = rows.map(&block) if block
      widths = max_length_of_each_column(rows)
      rows.map do |row|
        row.zip(widths).map { |value, width| value.ljust(width) }.join(" ")
      end
    end

    private

    def max_length_of_each_column(rows)
      rows.first.count.times.map do |i|
        rows.map { |values| values[i].to_s.length }.max
      end
    end
  end
end