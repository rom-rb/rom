# frozen_string_literal: true

require 'rom/plugin'

module ROM
  # Registry of all known plugin types (command, relation, mapper, etc)
  #
  # @api private
  module Plugins
    extend ::Dry::Core::Container::Mixin

    class << self
      # @api private
      def register(entity_type, plugin_type: Plugin, adapter: true)
        super(entity_type, plugin_type: plugin_type, adapter: adapter)
      end
    end
  end
end
