require "spec_helper"

describe Counters::Memory do
  subject do
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
      subject.namespace = "juice"
      subject.hit "foxglove"
      subject.hits["juice.foxglove"].should == 1
    end

    it "should namespace the key from #latency" do
      subject.namespace = "cocktail"
      subject.latency "angelica", 200
      subject.latencies["cocktail.angelica"].should == [200]
    end

    it "should namespace the key from #magnitude" do
      subject.namespace = "brew"
      subject.magnitude "crocus", 100
      subject.magnitudes["brew.crocus"].should == 100
    end

    it "should namespace the key from #ping" do
      subject.namespace = "beer"
      Timecop.freeze(Time.now.utc) do
        subject.ping "tulip"
        subject.pings["beer.tulip"].should == Time.now.utc
      end
    end
  end

  it "should record a hit with key 'pages.read'" do
    subject.hit "pages.read"
    subject.hits.should have_key("pages.read")
    subject.hits["pages.read"].should == 1

    subject.hit "pages.read"
    subject.hits["pages.read"].should == 2
  end

  it "should record a ping with key 'processor.alive'" do
    Timecop.freeze do
      subject.ping "processor.alive"
      subject.pings.should have_key("processor.alive")
      subject.pings["processor.alive"].strftime("%Y-%m-%d %H:%M:%S").should == Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    end

    target_time = Time.now + 9
    Timecop.travel(target_time) do
      subject.ping "processor.alive"
      subject.pings.should have_key("processor.alive")
      subject.pings["processor.alive"].strftime("%Y-%m-%d %H:%M:%S").should == target_time.utc.strftime("%Y-%m-%d %H:%M:%S")
    end
  end

  it "should record a latency with a passed value" do
    subject.latency "processor.enqueue", 0.00012
    subject.latencies["processor.enqueue"].should == [0.00012]

    subject.latency "processor.enqueue", 0.00121
    subject.latencies["processor.enqueue"].should == [0.00012, 0.00121]
  end

  it "should record a magnitude" do
    subject.magnitude "processor.bytes_compressed", 9_312
    subject.magnitude "processor.bytes_compressed", 8_271
    subject.magnitudes["processor.bytes_compressed"].should == 8_271
  end
end
