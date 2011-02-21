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

  it "should record a ping on 'crawler' by HSET counters/pings.crawler with today's date/time as an int" do
    Timecop.freeze do
      redis.should_receive(:hset).with("counters", "pings.crawler", Time.now.utc.to_i)
      counter.ping "crawler"
    end
  end
end
