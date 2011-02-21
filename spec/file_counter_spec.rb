require "spec_helper"
require "logger"
require "tempfile"

describe Counters::File do
  let! :tempfile do
    Tempfile.new("counters.log")
  end

  let! :counter do
    Counters::File.new(tempfile)
  end

  it "should log a message to the logfile when a hit is recorded" do
    counter.hit "urls.visited"
    tempfile.rewind
    tempfile.read.should =~ /hit.*urls\.visited/i
  end

  it "should log a message to the logfile when a magnitude is recorded" do
    counter.magnitude "bytes.read", 2_013
    tempfile.rewind
    tempfile.read.should =~ /magnitude.*bytes\.read.*2013/
  end

  it "should log a message to the logfile when a latency is recorded" do
    counter.latency "processing", 0.132 # in seconds
    tempfile.rewind
    tempfile.read.should =~ /latency.*processing.*0.132s/
  end

  it "should record a message in the logfile when a ping is recorded" do
    counter.ping "crawler.alive"
    tempfile.rewind
    tempfile.read.should =~ /ping.*crawler\.alive\s+\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{3,}/
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
end

describe Counters::File do
  it "should accept a filename on instantiation" do
    Counters::File.new("counters.log")
  end

  it "should accept a File instance on instantiation" do
    begin
      file = File.open("counters.log", "w")
      Counters::File.new(file)
    ensure
      File.unlink(file) if file
    end
  end

  it "should accept a Logger instance on instantiation" do
    logger = nil
    begin
      logger = Logger.new(File.open("counters.log", "w"))
      Counters::File.new(logger)
    ensure
      logger.close if logger
    end
  end

  it "should raise an ArgumentError when a bad type is used in the initializer" do
    lambda { Counters::File.new(nil) }.should raise_error(ArgumentError)
  end
end
