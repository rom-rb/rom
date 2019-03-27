# frozen_string_literal: true

require 'rom/plugin_base'

module ROM
  # @api private
  class SchemaPlugin < PluginBase
    include Configurable

    # Apply this plugin to the provided configuration
    #
    # @param [ROM::Schema] schema A schema instance for extension
    # @param [Hash] options Extension options
    #
    # @api private
    def apply_to(schema, options = EMPTY_HASH)
      mod.apply(schema, options) if mod.respond_to?(:apply)
    end

    # Extends a DSL instance with a module provided by the plugin
    #
    # @param [ROM::Schema::DSL] dsl
    #
    # @api private
    def extend_dsl(dsl)
      dsl.extend(mod.const_get(:DSL)) if mod.const_defined?(:DSL)
    end
  end
end
