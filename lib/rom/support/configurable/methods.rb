# frozen_string_literal: true

require "rom/support/configurable/errors"

module ROM
  module Configurable
    # Common API for both classes and instances
    #
    # @api public
    module Methods
      # @api public
      def configure(&block)
        raise FrozenConfig, "Cannot modify frozen config" if frozen?

        yield(config) if block
        self
      end

      # Finalize and freeze configuration
      #
      # @return [ROM::Configurable::Config]
      #
      # @api public
      def finalize!
        return self if config.frozen?

        config.finalize!
        self
      end
    end
  end
end
