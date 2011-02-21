require "benchmark"
require "logger"

module Counters
  class File < Counters::Base
    def initialize(path_or_io_or_logger)
      @file = if path_or_io_or_logger.kind_of?(Logger) then
                path_or_io_or_logger
              elsif path_or_io_or_logger.respond_to?(:<<) then
                Logger.new(path_or_io_or_logger)
              else
                raise ArgumentError, "Counters::File expects an object which is either a Logger or respond to #<<, received a #{path_or_io_or_logger.class}"
              end
    end

    def record_hit(key)
      @file.info "hit: #{key}"
    end

    def record_magnitude(key, magnitude)
      @file.info "magnitude: #{key} #{magnitude}"
    end

    def record_latency(key, time_in_seconds=nil)
      @file.info "latency: #{key} #{time_in_seconds}s"
    end

    def record_ping(key)
      @file.info "ping: #{key} #{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S.%N")}"
    end
  end
end
