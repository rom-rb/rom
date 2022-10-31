# frozen_string_literal: true

require "rom/support/configurable/config"
require "rom/support/configurable/methods"

module ROM
  module Configurable
    # Initializer method which is prepended when `ROM::Configurable`
    # is included in a class
    #
    # @api private
    module Initializer
      # @api private
      def initialize(*)
        # Dup settings at time of initializing to ensure setting values are specific to
        # this instance. This does mean that any settings defined on the class _after_
        # initialization will not be available on the instance.
        @config = Config.new(self.class._settings.dup)

        super
      end
      ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)
    end

    # Instance-level API when `ROM::Configurable` is included in a class
    #
    # @api public
    module InstanceMethods
      include Methods

      # Return object's configuration
      #
      # @return [Config]
      #
      # @api public
      attr_reader :config

      # Finalize the config and freeze the object
      #
      # @api public
      def finalize!
        return self if frozen?

        super
        freeze
      end

      private

      # @api public
      def initialize_copy(source)
        super
        @config = source.config.dup
      end
    end
  end
end
