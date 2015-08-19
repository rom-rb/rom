module ROM
  # TODO: remove this once deprecated Repository is gone in rom core
  class Gateway
  end

  class Repository < Gateway
    VERSION = '0.1.0'.freeze
  end
end
