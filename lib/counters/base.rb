module Counters
  class Base
    def hit(key)
      record_hit(key)
    end

    def magnitude(key, value)
      record_magnitude(key, value)
    end

    def latency(key, time_in_seconds=nil)
      if block_given? then
        raise ArgumentError, "Must pass either a latency or a block, not both: received #{time_in_seconds.inspect} in addition to a block" if time_in_seconds
        time_in_seconds = Benchmark.measure { yield }.real
      end

      record_latency(key, time_in_seconds)
    end

    def ping(key)
      record_ping(key)
    end

    def record_hit(key)
      raise "Subclass Responsibility Error: must be implemented in instances of #{self.class} but isn't"
    end
    protected :record_hit

    def record_magnitude(key)
      raise "Subclass Responsibility Error: must be implemented in instances of #{self.class} but isn't"
    end
    protected :record_magnitude

    def record_latency(key)
      raise "Subclass Responsibility Error: must be implemented in instances of #{self.class} but isn't"
    end
    protected :record_latency

    def record_ping(key)
      raise "Subclass Responsibility Error: must be implemented in instances of #{self.class} but isn't"
    end
    protected :record_ping
  end
end
