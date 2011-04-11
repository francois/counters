require "spec_helper"
require "logger"
require "tempfile"

describe Counters::File, "#initialize" do
  context "given an existing Logger instance" do
    let! :logger do
      Logger.new(STDOUT)
    end

    it "should use the existing Logger instance" do
      Logger.should_not_receive(:new)
      Counters::File.new(logger)
    end

    it "should not change the formatting" do
      logger.should_not_receive(:formatter=)
      Counters::File.new(logger)
    end
  end

  context "given an object that responds_to?(:add) (such as ActiveSupport::BufferedLogger)" do
    class FakeLogger
      def add(*args)
        raise "called for nothing"
      end
    end

    let! :logger do
      FakeLogger.new
    end

    it "should use the existing instance" do
      Logger.should_not_receive(:new)
      Counters::File.new(logger)
    end
  end

  context "given a String (representing a path)" do
    let :path do
      "log/mycounters.log"
    end

    let :logger do
      double("logger").as_null_object
    end

    it "should instantiate a Logger with the passed path" do
      Logger.should_receive(:new).with(path).and_return(logger)
      Counters::File.new(path)
    end

    it "should set the formatting" do
      Logger.stub(:new).and_return(logger)
      logger.should_receive(:formatter=)
      Counters::File.new(path)
    end
  end

  context "given an IO object" do
    let :io do
      STDOUT
    end

    let :logger do
      double("logger").as_null_object
    end

    it "should instantiate a Logger with the passed IO" do
      Logger.should_receive(:new).with(io).and_return(logger)
      Counters::File.new(io)
    end

    it "should set the formatting" do
      Logger.stub(:new).and_return(logger)
      logger.should_receive(:formatter=)
      Counters::File.new(io)
    end
  end

  it { lambda { Counters::File.new(nil) }.should raise_error(ArgumentError) }
  it { lambda { Counters::File.new("")  }.should raise_error(ArgumentError) }
end

describe Counters::File do
  TIMESTAMP_RE = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3,}/

  let :tempfile do
    Tempfile.new("counters.log")
  end

  let :counter do
    Counters::File.new(tempfile)
  end

  it_should_behave_like "all counters"

  context "#initialize" do
    it "should accept a namepsace in options" do
      counter = Counters::File.new(tempfile, :namespace => "wine")
      counter.namespace.should == "wine"
    end
  end

  context "given the counter is namespaced" do
    it "should namespace the key from #hit" do
      counter.namespace = "juice"
      counter.hit "foxglove"
      tempfile.rewind
      tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\shit:\sjuice\.foxglove$/
    end

    it "should namespace the key from #latency" do
      counter.namespace = "cocktail"
      counter.latency "angelica", 200
      tempfile.rewind
      tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\slatency:\scocktail\.angelica\s200s$/
    end

    it "should namespace the key from #magnitude" do
      counter.namespace = "brew"
      counter.magnitude "crocus", 100
      tempfile.rewind
      tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\smagnitude:\sbrew\.crocus 100$/
    end

    it "should namespace the key from #ping" do
      counter.namespace = "beer"
      counter.ping "tulip"
      tempfile.rewind
      tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\sping:\sbeer\.tulip$/
    end
  end

  it "should log a message to the logfile when a hit is recorded" do
    counter.hit "urls.visited"
    tempfile.rewind
    tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\shit.*urls\.visited$/
  end

  it "should log a message to the logfile when a magnitude is recorded" do
    counter.magnitude "bytes.read", 2_013
    tempfile.rewind
    tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\smagnitude.*bytes\.read.*2013$/
  end

  it "should log a message to the logfile when a latency is recorded" do
    counter.latency "processing", 0.132 # in seconds
    tempfile.rewind
    tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\slatency.*processing.*0.132s$/
  end

  it "should record a message in the logfile when a ping is recorded" do
    counter.ping "crawler.alive"
    tempfile.rewind
    tempfile.read.should =~ /^#{TIMESTAMP_RE}\s-\sping.*crawler\.alive$/
  end

  it "should log a message to the logfile when a latency is recorded using a block" do
    counter.latency "crawling" do
      sleep 0.1
    end

    tempfile.rewind
    tempfile.read.should =~ /latency.*crawling.*0.1\d+s/
  end

  it "should raise an ArgumentError when calling #latency with both a block and a latency" do
    lambda { counter.latency("processing", 0.123) { sleep 0.1 } }.should raise_error(ArgumentError)
  end

  it "should accept a filename on instantiation" do
    Counters::File.new("counters.log")
  end

  it "should accept a File instance on instantiation" do
    Counters::File.new( File.open("counters.log", "w") )
  end

  it "should accept a Logger instance on instantiation" do
    Counters::File.new( Logger.new("counters.log") )
  end

  it "should raise an ArgumentError when a bad type is used in the initializer" do
    lambda { Counters::File.new(nil) }.should raise_error(ArgumentError)
  end

  after(:each) do
    fname = File.dirname(__FILE__) + "/../counters.log"
    File.unlink(fname) if File.exist?(fname)
  end
end
