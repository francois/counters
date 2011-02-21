require "benchmark"
require "logger"

module Counters
  class File
    def initialize(path_or_io_or_logger)
      @file = if path_or_io_or_logger.kind_of?(Logger) then
                path_or_io_or_logger
              elsif path_or_io_or_logger.respond_to?(:<<) then
                Logger.new(path_or_io_or_logger)
              else
                raise ArgumentError, "Counters::File expects an object which is either a Logger or respond to #<<, received a #{path_or_io_or_logger.class}"
              end
    end

    def hit(key)
      @file.info "hit: #{key}"
    end

    def magnitude(key, magnitude)
      @file.info "magnitude: #{key} #{magnitude}"
    end

    def latency(key, time_in_seconds=nil)
      if block_given? then
        raise ArgumentError, "Must pass either a latency or a block, not both: received #{time_in_seconds.inspect} in addition to a block" if time_in_seconds
        time_in_seconds = Benchmark.measure { yield }.real
      end

      @file.info "latency: #{key} #{time_in_seconds}s"
    end
  end
end
