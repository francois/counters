require "counters"
require "timecop"

begin
  require "ruby-debug"
rescue LoadError
  # Optional dependency - ignoring
end

shared_examples_for "all counters" do
  it "should raise a ArgumentError when the key includes invalid chars" do
    lambda { counter.hit "hit!"        } .should raise_error(ArgumentError)
    lambda { counter.hit "hit counter" } .should raise_error(ArgumentError)
    lambda { counter.hit "boy.hit?"    } .should raise_error(ArgumentError)
    lambda { counter.hit "hit/a"       } .should raise_error(ArgumentError)
    lambda { counter.hit "hit-a"       } .should raise_error(ArgumentError)
    lambda { counter.hit ""            } .should raise_error(ArgumentError)
    lambda { counter.hit nil           } .should raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes a number" do
    lambda { counter.hit "hit1" }.should_not raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes a dot / fullstop" do
    lambda { counter.hit "hit." }.should_not raise_error(ArgumentError)
  end

  it "should not raise ArgumentError when the key includes an underscore" do
    lambda { counter.hit "hit_" }.should_not raise_error(ArgumentError)
  end
end
