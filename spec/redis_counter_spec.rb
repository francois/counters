require "spec_helper"

describe Counters::Redis do
  let :redis do
    double("redis")
  end

  let :counter do
    Counters::Redis.new(redis, "counters")
  end

  it_should_behave_like "all counters"

  it "should record a hit on 'pages.read' by HINCRBY counters/hits.pages.read" do
    redis.should_receive(:hincrby).with("counters", "hits.pages.read", 1).twice
    2.times { counter.hit "pages.read" }
  end

  it "should record a magnitude on 'bytes.in' by HINCRBY counters/magnitudes.bytes.in" do
    redis.should_receive(:hincrby).with("counters", "magnitudes.bytes.in", 309).once
    redis.should_receive(:hincrby).with("counters", "magnitudes.bytes.in", 392).once
    counter.magnitude "bytes.in", 309
    counter.magnitude "bytes.in", 392
  end

  it "should record a ping on 'crawler' by HSET counters/pings.crawler with today's date/time as an int" do
    Timecop.freeze do
      redis.should_receive(:hset).with("counters", "pings.crawler", Time.now.utc.to_i).once
      counter.ping "crawler"
    end

    target_time = Time.now + 9
    Timecop.travel(target_time) do
      redis.should_receive(:hset).with("counters", "pings.crawler", target_time.to_i).once
      counter.ping "crawler"
    end
  end

  it "should record latency on 'crawler.download' by HINCRBY counters/latencies.crawler.download.count by 1 and counters/latencies.crawler.download.nanoseconds by the latency" do
    redis.should_receive(:hincrby).with("counters", "latencies.crawler.download.count", 1).twice
    redis.should_receive(:hincrby).with("counters", "latencies.crawler.download.nanoseconds", 1.90 * 1_000_000_000).once
    redis.should_receive(:hincrby).with("counters", "latencies.crawler.download.nanoseconds", 2.02 * 1_000_000_000).once

    counter.latency "crawler.download", 1.9
    counter.latency "crawler.download", 2.02
  end

  it "should record a block's latency" do
    redis.should_receive(:hincrby).with("counters", "latencies.crawler.process.count", 1).once
    redis.should_receive(:hincrby).once.with do |key, subkey, latency|
      key == "counters" && subkey == "latencies.crawler.process.nanoseconds" && latency >= 0.2 * 1_000_000_000 && latency < 0.3 * 1_000_000_000
    end
    counter.latency "crawler.process" do
      sleep 0.2
    end
  end
end
