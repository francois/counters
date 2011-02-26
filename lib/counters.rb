# A simple way to record performance counters / metrics.
#
# All performance counters can be broken down into a few categories:
#
# * +ping+ Just to know something is still alive. You'd probably graph "now() - ping".
# * +hit+ Increments a counter. In this case you'd graph the 1st derivative, to see how the slope of changes.
# * +latency+ Increments a counter representing time. You'd again graph the 1st derivative.
# * +magnitude+ Sets a counter representing a value (bytes, free RAM, etc). Here you'd graph min, max, avg and stdev.
module Counters
  autoload :Base, "counters/base"
  autoload :Redis, "counters/redis"
  autoload :Memory, "counters/memory"
  autoload :File, "counters/file"
end
