module Counters
  # Raised whenever an invalid key is used
  class InvalidKey < RuntimeError; end

  autoload :Base, "counters/base"
  autoload :Redis, "counters/redis"
  autoload :Memory, "counters/memory"
  autoload :File, "counters/file"
end
