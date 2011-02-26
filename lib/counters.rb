module Counters
  autoload :Base, "counters/base"
  autoload :Redis, "counters/redis"
  autoload :Memory, "counters/memory"
  autoload :File, "counters/file"
end
