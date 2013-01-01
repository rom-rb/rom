module DataMapper
  class Session
    # Error raised when session misses a mapper
    class MissingMapperError < RuntimeError
    end
  end
end
