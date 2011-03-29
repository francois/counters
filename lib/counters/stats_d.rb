require "socket"

module Counters
  class StatsD < Counters::Base
    attr_reader :host, :port, :socket

    def initialize(host, port, options={})
      super(options)

      @host, @port = host, port
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
