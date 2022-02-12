# frozen_string_literal: true

require "dry/container"

module ROM
  module Registries
    # @api private
    class Container
      include Dry::Container::Mixin
    end
  end
end
