require "spec_helper"

describe Counters::StatsD, "#initialize" do
  it "should accept a Hash with a :url key" do
    counter = Counters::StatsD.new(:url => "statsd://statsd.internal:9991")
    counter.host.should == "statsd.internal"
    counter.port.should == 9991
  end

  it "should accept a host/port pair" do
    counter = Counters::StatsD.new("127.0.0.1", 8125)
    counter.host.should == "127.0.0.1"
    counter.port.should == 8125
  end
end

describe Counters::StatsD do
  let :socket do
    double("socket")
  end

  let :host do
    "127.0.0.1"
  end

  let :port do
    8125
  end

  let :counter do
    Counters::StatsD.new(host, port, :socket => socket)
  end

  context "" do
    before(:each) do
      socket.as_null_object
    end

    it_should_behave_like "all counters"
  end

  it "should record a hit as an increment of the key" do
    socket.should_receive(:send).with("hits.tweets_received:1|c", 0, host, port)
    counter.hit "tweets_received"
  end

  it "should record a magnitude as a timer" do
    socket.should_receive(:send).with("magnitudes.bytes_in:381|ms", 0, host, port)
    counter.magnitude "bytes_in", 381
  end

  it "should record a latency as a timer" do
    socket.should_receive(:send).with("latencies.json_parsing:9|ms", 0, host, port)
    counter.latency "json_parsing", 0.009
  end

  it "should record a ping as a counter" do
    socket.should_receive(:send).with("pings.tweet_processor:1|c", 0, host, port)
    counter.ping "tweet_processor"
  end

  context "#initialize" do
    it "should accept a namepsace in options" do
      counter = Counters::StatsD.new(host, port, :namespace => "wine")
      counter.namespace.should == "wine"
    end
  end

  context "given the counter is namespaced" do
    it "should namespace the key from #hit" do
      counter.namespace = "juice"
      socket.should_receive(:send).with(/^hits\.juice\.foxglove\b/, anything, anything, anything)
      counter.hit "foxglove"
    end

    it "should namespace the key from #latency" do
      counter.namespace = "cocktail"
      socket.should_receive(:send).with(/^latencies\.cocktail\.angelica\b/, anything, anything, anything)
      counter.latency "angelica", 200
    end

    it "should namespace the key from #magnitude" do
      counter.namespace = "brew"
      socket.should_receive(:send).with(/^magnitudes\.brew\.crocus\b/, anything, anything, anything)
      counter.magnitude "crocus", 100
    end

    it "should namespace the key from #ping" do
      counter.namespace = "beer"
      socket.should_receive(:send).with(/^pings\.beer\.tulip\b/, anything, anything, anything)
      counter.ping "tulip"
    end
  end
end
