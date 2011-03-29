require "spec_helper"

describe Counters::Memory do
  let :counter do
    Counters::Memory.new
  end

  it_should_behave_like "all counters"

  context "#initialize" do
    it "should accept a namepsace in options" do
      counter = Counters::Memory.new(:namespace => "wine")
      counter.namespace.should == "wine"
    end
  end

  context "given the counter is namespaced" do
    it "should namespace the key from #hit" do
      counter.namespace = "juice"
      counter.hit "foxglove"
      counter.hits["juice.foxglove"].should == 1
    end

    it "should namespace the key from #latency" do
      counter.namespace = "cocktail"
      counter.latency "angelica", 200
      counter.latencies["cocktail.angelica"].should == [200]
    end

    it "should namespace the key from #magnitude" do
      counter.namespace = "brew"
      counter.magnitude "crocus", 100
      counter.magnitudes["brew.crocus"].should == 100
    end

    it "should namespace the key from #ping" do
      counter.namespace = "beer"
      Timecop.freeze(Time.now.utc) do
        counter.ping "tulip"
        counter.pings["beer.tulip"].should == Time.now.utc
      end
    end
  end

  it "should record a hit with key 'pages.read'" do
    counter.hit "pages.read"
    counter.hits.should have_key("pages.read")
    counter.hits["pages.read"].should == 1

    counter.hit "pages.read"
    counter.hits["pages.read"].should == 2
  end

  it "should record a ping with key 'processor.alive'" do
    Timecop.freeze do
      counter.ping "processor.alive"
      counter.pings.should have_key("processor.alive")
      counter.pings["processor.alive"].strftime("%Y-%m-%d %H:%M:%S").should == Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    end

    target_time = Time.now + 9
    Timecop.travel(target_time) do
      counter.ping "processor.alive"
      counter.pings.should have_key("processor.alive")
      counter.pings["processor.alive"].strftime("%Y-%m-%d %H:%M:%S").should == target_time.utc.strftime("%Y-%m-%d %H:%M:%S")
    end
  end

  it "should record a latency with a passed value" do
    counter.latency "processor.enqueue", 0.00012
    counter.latencies["processor.enqueue"].should == [0.00012]

    counter.latency "processor.enqueue", 0.00121
    counter.latencies["processor.enqueue"].should == [0.00012, 0.00121]
  end

  it "should record a magnitude" do
    counter.magnitude "processor.bytes_compressed", 9_312
    counter.magnitude "processor.bytes_compressed", 8_271
    counter.magnitudes["processor.bytes_compressed"].should == 8_271
  end
end
