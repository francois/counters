require "socket"
require "uri"

module Counters
  class StatsD < Counters::Base
    attr_reader :host, :port, :socket

    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      super(options)

      url = case args.length
            when 0
              options.fetch(:url) { raise ArgumentError, "Missing :url key from #{args.first}" }
            when 2
              "statsd://#{args.first}:#{args.last}"
            else
              raise ArgumentError, "Expected either a Hash or a host and port arguments, found: #{args.inspect}"
            end

      uri = URI.parse(url)
      @host, @port = uri.host, uri.port
      @socket = options.fetch(:socket) { UDPSocket.new }
    end

    def record_ping(key)
      socket.send("pings.#{key}:1|c", 0, host, port)
    end

    def record_hit(key)
      socket.send("hits.#{key}:1|c", 0, host, port)
    end

    # StatsD expects millisecond resolution
    SCALING_FACTOR = 1_000

    def record_latency(key, time_in_seconds)
      value = "latencies.%s:%d|ms" % [key, time_in_seconds * SCALING_FACTOR]
      socket.send(value, 0, host, port)
    end

    def record_magnitude(key, amount)
      value = "magnitudes.%s:%d|ms" % [key, amount]
      socket.send(value, 0, host, port)
    end
  end
end
