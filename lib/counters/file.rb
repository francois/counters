require "logger"

module Counters
  class File < Counters::Base
    def initialize(path_or_io_or_logger, options={})
      super(options)

      @logger = if path_or_io_or_logger.kind_of?(Logger) || path_or_io_or_logger.respond_to?(:add) then
                  path_or_io_or_logger

                elsif path_or_io_or_logger.respond_to?(:to_str) then
                  # path to something
                  raise ArgumentError, "Counters::File expects a path with a non-empty name (or a Logger, IO instance); received: #{path_or_io_or_logger.inspect}" if path_or_io_or_logger.to_str.empty?

                  logger = Logger.new(path_or_io_or_logger)
                  logger.formatter = lambda {|severity, datetime, progname, msg| "#{datetime.strftime("%Y-%m-%dT%H:%M:%S.%N")} - #{msg}\n"}
                  logger

                elsif path_or_io_or_logger.respond_to?(:<<) then
                  # IO instance
                  logger = Logger.new(path_or_io_or_logger)
                  logger.formatter = lambda {|severity, datetime, progname, msg| "#{datetime.strftime("%Y-%m-%dT%H:%M:%S.%N")} - #{msg}\n"}
                  logger

                else
                  raise ArgumentError, "Counters::File expects an object which is either a Logger or respond to #<<, received a #{path_or_io_or_logger.class}"
                end
    end

    def record_hit(key, increment)
      @logger.info "hit: #{key}#{ increment == 1 ? "" : ": #{increment}"}"
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
