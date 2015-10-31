module ROM
  # TODO: remove this once deprecated Repository is gone in rom core
  class Gateway
  end

  class Repository < Gateway
    VERSION = '0.2.0.beta1'.freeze
  end
end
