# frozen_string_literal: true

require "delegate"

require "rom/constants"
require "rom/components"

module ROM
  module Runtime
    class Container
      include Dry::Container::Mixin
    end

    class Configuration < SimpleDelegator
      include Dry::Equalizer(:configuration)

      alias_method :configuration, :__getobj__

      attr_reader :container

      # @api private
      def initialize(configuration: ROM::Configuration.new, container: Container.new)
        super(configuration)
        @container = container
      end

      Components::CORE_TYPES.each do |type|
        define_method(type) do
          resolver(type)
        end
      end

      # @api private
      def register(type, resolver)
        container.register(type, resolver)
      end

      # @api private
      def resolver(type)
        key?(type) ? container[type] : Runtime::Resolver.new(type, configuration: self)
      end

      # @api private
      def key?(key)
        container.key?(key)
      end

      # @api private
      def cache
        configuration.cache
      end
    end
  end
end
