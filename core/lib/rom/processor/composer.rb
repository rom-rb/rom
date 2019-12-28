# frozen_string_literal: true

module ROM
  class Processor
    # @api private
    module Composer
      # @api private
      class Factory
        attr_reader :fns, :default

        # @api private
        def initialize(default = nil)
          @fns = []
          @default = default
        end

        # @api private
        def <<(other)
          fns.concat(Array(other).compact)
          self
        end

        # @api private
        def to_fn
          fns.reduce(:+) || default
        end
      end

      # @api private
      def compose(default = nil)
        factory = Factory.new(default)
        yield(factory)
        factory.to_fn
      end
    end
  end
end
