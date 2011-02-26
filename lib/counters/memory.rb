require "counters"

module Counters
  class Memory < Counters::Base
    attr_reader :hits, :latencies, :magnitudes, :pings

    def initialize
      @hits       = Hash.new {|h,k| h[k] = 0}
      @magnitudes = Hash.new {|h,k| h[k] = 0}
      @latencies  = Hash.new {|h,k| h[k] = Array.new}
      @pings      = Hash.new
    end

    def record_hit(key)
      @hits[key] += 1
    end

    def record_ping(key)
      @pings[key] = Time.now
    end

    def record_latency(key, time_in_seconds)
      @latencies[key] << time_in_seconds
    end

    def record_magnitude(key, value)
      @magnitudes[key] = value
    end
  end
end
