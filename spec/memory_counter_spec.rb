require "spec_helper"

describe Counters::Memory do
  let :counter do
    Counters::Memory.new
  end

  it "should record a hit with key 'pages.read'" do
    counter.hit "pages.read"
    counter.hits.should have_key("pages.read")
    counter.hits["pages.read"].should == 1
  end
end
