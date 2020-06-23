# frozen_string_literal: true

require "rom/plugin"

module ROM
  # @api private
  class SchemaPlugin < Plugin
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
