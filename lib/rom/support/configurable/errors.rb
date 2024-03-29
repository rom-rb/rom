# frozen_string_literal: true

module ROM
  # Shared errors
  #
  # @api public
  module Configurable
    Error = Class.new(::StandardError)
    AlreadyIncluded = ::Class.new(Error)
    FrozenConfig = ::Class.new(Error)
  end
end
