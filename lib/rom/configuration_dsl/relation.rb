# frozen_string_literal: true

require "dry/core/class_builder"
require "rom/support/inflector"

module ROM
  module ConfigurationDSL
    # Setup DSL-specific relation extensions
    #
    # @private
    class Relation
      # Generate a relation subclass
      #
      # This is used by Setup#relation DSL
      #
      # @api private
      def self.build_class(name, options = EMPTY_HASH)
        inflector = options.fetch(:inflector) { Inflector }
        class_name = "ROM::Relation[#{inflector.camelize(name)}]"
        adapter = options.fetch(:adapter)

        Dry::Core::ClassBuilder.new(name: class_name,
                                    parent: ROM::Relation[adapter]).call do |klass|
          klass.gateway(options.fetch(:gateway, :default))
        end
      end
    end
  end
end
