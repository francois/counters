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
end
