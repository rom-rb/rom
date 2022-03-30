# frozen_string_literal: true

require "dry/container"

require "rom/constants"
require "rom/plugin"

require "rom/plugins/dsl"
require "rom/plugins/relation/registry_reader"
require "rom/plugins/relation/instrumentation"
require "rom/plugins/relation/changeset"
require "rom/plugins/command/schema"
require "rom/plugins/command/timestamps"
require "rom/plugins/schema/timestamps"

module ROM
  # Registry of all known plugins
  #
  # @api public
  module Plugins
    extend Dry::Container::Mixin
    extend Enumerable

    module_function

    def dsl(*args, &block)
      Plugins::DSL.new(self, *args, &block)
    end

    # @api private
    def register(name, type:, **options)
      Plugin.new(name: name, type: type, **options).tap do |plugin|
        super(plugin.key, plugin)
      end
    end

    # @api private
    def each
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
        elsif _adapter && key?(name)
          fetch(name, _adapter)
        else
            key = "#{type}.#{name}"
            container.resolve(key)
        end
      end
      alias_method :[], :fetch

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
