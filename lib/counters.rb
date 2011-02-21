module Counters
  class Memory
    attr_reader :hits

    def initialize
      @hits = Hash.new {|h,k| h[k] = 0}
    end

    def hit(key)
      @hits[key] += 1
    end
  end

  class Redis
    def initialize(redis, base_key)
      @redis, @base_key = redis, base_key
    end

    def hit(key)
      @redis.hincrby(@base_key, "hits.#{key}", 1)
    end
  end
end
