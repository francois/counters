require "benchmark"

module Counters
  class Base

    attr_writer :namespace

    def initialize(options={})
      @options   = options
      @namespace = options[:namespace]
    end

    def hit(key, value=1)
      validate(key)
      record_hit(namespaced_key(key), value)
    end

    def magnitude(key, value)
      validate(key)
      record_magnitude(namespaced_key(key), value)
    end

    def latency(key, time_in_seconds=nil)
      result = nil
      validate(key)
      if block_given? then
        raise ArgumentError, "Must pass either a latency or a block, not both: received #{time_in_seconds.inspect} in addition to a block" if time_in_seconds
        time_in_seconds = Benchmark.measure { result = yield }.real
      end

      record_latency(namespaced_key(key), time_in_seconds)
      result
    end

    def ping(key)
      validate(key)
      record_ping(namespaced_key(key))
    end

    def namespace(*args)
      if args.empty? then
        @namespace
      else
        other = self.dup
        other.namespace = [@namespace.to_s, args.first].join(".")
        other
      end
    end

    def record_hit(key, value)
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

    def validate(key)
      key.to_s =~ /\A[.\w]+\Z/i or raise ArgumentError, "Keys can contain only letters, numbers, the underscore (_) and fullstop (.), received #{key.inspect}"
    end
    private :validate

    def namespaced_key(key)
      return key if namespace.nil?
      "#{namespace}.#{key}"
    end
    private :namespaced_key

  end
end
