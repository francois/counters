require "spec_helper"

describe Counters::Redis do
  let :redis do
    double("redis")
  end

  let :counter do
    Counters::Redis.new(redis, "counters")
  end

  it "should record a hit on 'pages.read' by HINCRBY counters/hits.pages.read" do
    redis.should_receive(:hincrby).with("counters", "hits.pages.read", 1)
    counter.hit "pages.read"
  end

  it "should record a magnitude on 'bytes.in' by HINCRBY counters/magnitudes.bytes.in" do
    redis.should_receive(:hincrby).with("counters", "magnitudes.bytes.in", 309)
    counter.magnitude "bytes.in", 309
  end
end
