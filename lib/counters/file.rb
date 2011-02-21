require "benchmark"
require "logger"

module Counters
  class File < Counters::Base
    def initialize(path_or_io_or_logger)
      @logger = if path_or_io_or_logger.kind_of?(Logger) then
                path_or_io_or_logger
              elsif path_or_io_or_logger.respond_to?(:<<) then
                Logger.new(path_or_io_or_logger)
              else
                raise ArgumentError, "Counters::File expects an object which is either a Logger or respond to #<<, received a #{path_or_io_or_logger.class}"
              end

      @logger.formatter = lambda {|severity, datetime, progname, msg| "#{datetime.strftime("%Y-%m-%dT%H:%M:%S.%N")} - #{msg}\n"}
    end

    def record_hit(key)
      @logger.info "hit: #{key}"
    end

    def record_magnitude(key, magnitude)
      @logger.info "magnitude: #{key} #{magnitude}"
    end

    def record_latency(key, time_in_seconds=nil)
      @logger.info "latency: #{key} #{time_in_seconds}s"
    end

    def record_ping(key)
      @logger.info "ping: #{key}"
    end
  end
end
