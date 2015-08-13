module ROM
  # TODO: remove this once deprecated Repository is gone in rom core
  class Gateway
  end

  class Repository < Gateway
    VERSION = '0.0.3'.freeze
  end
end
