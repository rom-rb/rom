# frozen_string_literal: true

require "dry/container"
require "rom/plugin"

module ROM
  # Registry of all known plugin types (command, relation, mapper, etc)
  #
  # @api private
  module Plugins
    extend ::Dry::Container::Mixin

    class << self
      # @api private
      def register(entity_type, plugin_type: Plugin, adapter: true)
        super(entity_type, plugin_type: plugin_type, adapter: adapter)
      end
    end
  end
end
