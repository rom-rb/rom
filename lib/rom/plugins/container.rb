# frozen_string_literal: true

require "dry/container"

require "rom/constants"
require "rom/plugin"
require "rom/schema_plugin"

module ROM
  module Plugins
    # Registry of all known plugin types (command, relation, mapper, etc)
    #
    # @api private
    class Container
      include Dry::Container::Mixin
      include Enumerable

      TYPES = {
        schema: SchemaPlugin
      }.freeze

      # @api private
      def register(name, type:, **options)
        plugin = TYPES.fetch(type, Plugin).new(name: name, type: type, **options)

        super(plugin.key, plugin)
      end

      # @api private
      def each(&block)
        keys.each { |key| yield(self[key]) }
      end

      # @api private
      def resolve(key)
        super
      rescue Dry::Container::Error
        raise ROM::UnknownPluginError, "+#{key}+ plugin was not found"
      end

      # TODO: move to rom/compat
      # @api private
      class Resolver
        attr_reader :container, :type, :_adapter

        # @api private
        def initialize(container, type:, adapter: nil)
          @container = container
          @type = type
          @_adapter = adapter
        end

        # @api private
        def adapter(name)
          self.class.new(container, type: type, adapter: name)
        end

        # @api private
        def fetch(name, adapter = nil)
          if adapter
            key = [adapter, type, name].compact.join(".")

            if container.key?(key)
              container.resolve(key)
            else
              fetch(name)
            end
          else
            if _adapter && key?(name)
              fetch(name, _adapter)
            else
              key = "#{type}.#{name}"
              container.resolve(key)
            end
          end
        end

        # @api private
        def key?(name)
          container.key?([_adapter, type, name].compact.join("."))
        end
      end

      # @api private
      def [](key)
        if key?(key)
          super
        else
          Resolver.new(self, type: key)
        end
      end
    end
  end
end
