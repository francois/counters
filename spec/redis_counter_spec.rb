require "spec_helper"
require "redis"

describe Counters::Redis, "integration tests" do
  let :redis do
    ::Redis.new
  end

  let :counter do
    Counters::Redis.new(redis, "counters")
  end

  before(:each) do
    redis.flushdb
  end

  it_should_behave_like "all counters"

  it "should record 2 hits on 'pages.read'" do
    2.times { counter.hit "pages.read" }
    redis.hkeys("counters").should == ["hits.pages.read"]
    redis.hget("counters", "hits.pages.read").to_i.should == 2
  end

  it "should record magnitude using a signed 64 bit 'value' and a 'count'" do
    4.times { counter.magnitude "bytes.in", 2_047 }
    redis.hkeys("counters").sort.should == %w(magnitudes.bytes.in.value magnitudes.bytes.in.count).sort

    redis.hget("counters", "magnitudes.bytes.in.count").to_i.should == 4
    redis.hget("counters", "magnitudes.bytes.in.value").to_i.should == 4*2_047
  end

  it "does not detect 63 bit integer overflow" do
    counter.magnitude "bytes.in", 2**63 - 20
    counter.magnitude "bytes.in", 2_047

    target_value = (2**63 - 20) + 2_047

    redis.hget("counters", "magnitudes.bytes.in.value").to_i.should == (target_value - 2**64)
    redis.hget("counters", "magnitudes.bytes.in.count").to_i.should == 2
  end

  it "should record a ping on 'crawler' by HSET counters/pings.crawler with today's date/time as an int" do
    now = Time.now
    Timecop.freeze(now) do
      counter.ping "crawler"
    end

    redis.hget("counters", "pings.crawler").should == now.to_i.to_s

    target_time = Time.now + 9
    Timecop.travel(target_time) do
      counter.ping "crawler"
    end

    redis.hget("counters", "pings.crawler").should == target_time.to_i.to_s
  end

  it "should record latency on 'crawler.download' by HINCRBY counters/latencies.crawler.download.count by 1 and counters/latencies.crawler.download.nanoseconds by the latency" do
    counter.latency "crawler.download", 1.9
    counter.latency "crawler.download", 2.02

    redis.hget("counters", "latencies.crawler.download.count").to_i.should == 2
    redis.hget("counters", "latencies.crawler.download.nanoseconds").to_i.should == (2.02 + 1.90) * ONE_NANOSECOND
  end

  it "should record a block's latency" do
    counter.latency "crawler.process" do
      sleep 0.2
    end

    redis.hget("counters", "latencies.crawler.process.count").to_i.should == 1
    redis.hget("counters", "latencies.crawler.process.nanoseconds").to_i.should be_within(0.01 * ONE_NANOSECOND ).of ( 0.2 * ONE_NANOSECOND )
  end

  ONE_NANOSECOND = 1_000_000_000
end
