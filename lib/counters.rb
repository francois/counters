module Counters
  autoload :Redis, "counters/redis"
  autoload :Memory, "counters/memory"
  autoload :File, "counters/file"
end
