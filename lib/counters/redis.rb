require "counters"

module Counters
  class Redis
    def initialize(redis, base_key)
      @redis, @base_key = redis, base_key
    end

    def hit(key)
      @redis.hincrby(@base_key, "hits.#{key}", 1)
    end
  end
end
