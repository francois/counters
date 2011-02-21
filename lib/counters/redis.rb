require "counters"

module Counters
  class Redis
    def initialize(redis, base_key)
      @redis, @base_key = redis, base_key
    end

    def hit(key)
      @redis.hincrby(@base_key, "hits.#{key}", 1)
    end

    def magnitude(key, amount)
      @redis.hincrby(@base_key, "magnitudes.#{key}", amount)
    end

    def ping(key)
      @redis.hset(@base_key, "pings.#{key}", Time.now.to_i)
    end
  end
end
