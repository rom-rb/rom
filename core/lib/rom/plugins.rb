# frozen_string_literal: true

require 'dry/container'
require 'rom/plugin'

module ROM
  # Registry of all known plugin types (command, relation, mapper, etc)
  #
  # @api private
  module Plugins
    @registry = ::Dry::Container.new

    class << self
      # @api private
      def register(entity_type, plugin_type: Plugin, adapter: true)
        @registry.register(entity_type, plugin_type: plugin_type, adapter: adapter)
      end

      # @api private
      def [](entity_type)
        @registry[entity_type]
      end
    end
  end
end
