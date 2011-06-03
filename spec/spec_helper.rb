require "counters"
require "timecop"

begin
  require "ruby-debug"
rescue LoadError
  # Optional dependency - ignoring
end

shared_examples_for "all counters" do
  it "should raise a ArgumentError when the key includes invalid chars" do
    lambda { subject.hit "hit!"        }.should raise_error(ArgumentError)
    lambda { subject.hit "hit counter" }.should raise_error(ArgumentError)
    lambda { subject.hit "boy.hit?"    }.should raise_error(ArgumentError)
    lambda { subject.hit "hit/a"       }.should raise_error(ArgumentError)
    lambda { subject.hit "hit-a"       }.should raise_error(ArgumentError)
    lambda { subject.hit ""            }.should raise_error(ArgumentError)
    lambda { subject.hit nil           }.should raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes a number" do
    lambda { subject.hit "hit1" }.should_not raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes a dot / fullstop" do
    lambda { subject.hit "hit." }.should_not raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes an underscore" do
    lambda { subject.hit "hit_" }.should_not raise_error(ArgumentError)
  end

  it "should return the latency block's value" do
    value = subject.latency "process" do
      "the returned value"
    end

    value.should == "the returned value"
  end

  it "should allow hitting with a specific value increment" do
    lambda { subject.hit "tada", 17 }.should_not raise_error
  end

  it "should return a sub-namespaced counter on-demand" do
    other = subject.namespace("sub")
    other.namespace.should == "#{subject.namespace}.sub"
  end
end
