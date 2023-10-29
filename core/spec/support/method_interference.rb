# frozen_string_literal: true

# This mocks Object#with to simulate ActiveSupport 7.1
# whose definition of #with caused interference
class Object
  def with(*args, **kwargs, &block)
    Kernel.raise("Object#with conflict")
  end
end
