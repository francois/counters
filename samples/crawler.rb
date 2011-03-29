require "uri"
require "open-uri"
require "counters"
require "nokogiri"
require "redis"
require "pp"

# Counter = Counters::Redis.new(Redis.new, :namespace => "crawler", :base_key => "counters")
Counter = Counters::StatsD.new("127.0.0.1", 8125, :namespace => "crawler")
# Counter = Counters::Memory.new(:namespace => "crawler")
# Counter = Counters::File.new(STDOUT, :namespace => "crawler")

urls_to_crawl = ["http://blog.teksol.info/", "http://techcrunch.com/", "http://www.google.com/"]

while url = urls_to_crawl.pop
  Counter.ping "crawler"

  begin
    Counter.hit "urls_popped"

    puts "Fetching #{url}"
    raw_html = Counter.latency "download" do
      URI.parse(url).read
    end

    Counter.magnitude "bytes_in", raw_html.length

    parsed_html = Counter.latency "html_parsing" do
      Nokogiri::HTML(raw_html)
    end
  rescue
    Counter.hit "error"
  end
end

pp Counter if Counter.instance_of?(Counters::Memory)
pp Redis.new.hgetall("counters") if Counter.instance_of?(Counters::Redis)
