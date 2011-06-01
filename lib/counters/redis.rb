# The redis gem must already be required - we don't require it.
# This allows callers / users to use any implementation that has the right API.

module Counters
  class Redis < Counters::Base
    def initialize(redis=Redis.new, options={})
      super(options)

      @redis    = redis
      @base_key = options.fetch(:base_key) { raise "Missing :base_key from #{options.inspect}" }
    end

    def record_hit(key, increment)
      @redis.hincrby(@base_key, "hits.#{key}", increment)
    end

    def record_magnitude(key, amount)
      @redis.multi do
        @redis.hincrby(@base_key, "magnitudes.#{key}.value", amount)
        @redis.hincrby(@base_key, "magnitudes.#{key}.count", 1)
      end
    end

    def record_ping(key)
      @redis.hset(@base_key, "pings.#{key}", Time.now.utc.to_i)
    end

    # Redis requires integer keys, thus we scale all latencies to the nanosecond precision
    SCALING_FACTOR = 1_000_000_000

    def record_latency(key, latency_in_seconds)
      @redis.hincrby(@base_key, "latencies.#{key}.count", 1)
      @redis.hincrby(@base_key, "latencies.#{key}.nanoseconds", (latency_in_seconds * SCALING_FACTOR).to_i)
    end
  end
end
