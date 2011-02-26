require "benchmark"
require "counters"

module Counters
  class Redis < Counters::Base
    def initialize(redis, base_key)
      @redis, @base_key = redis, base_key
    end

    def record_hit(key)
      @redis.hincrby(@base_key, "hits.#{key}", 1)
    end

    def record_magnitude(key, amount)
      @redis.hset(@base_key, "magnitudes.#{key}", amount)
    end

    def ping(key)
      @redis.hset(@base_key, "pings.#{key}", Time.now.to_i)
    end

    # Redis requires integer keys, thus we scale all latencies to the nanosecond precision
    SCALING_FACTOR = 1_000_000_000

    def record_latency(key, latency_in_seconds)
      @redis.hincrby(@base_key, "latencies.#{key}.count", 1)
      @redis.hincrby(@base_key, "latencies.#{key}.nanoseconds", (latency_in_seconds * SCALING_FACTOR).to_i)
    end
  end
end
