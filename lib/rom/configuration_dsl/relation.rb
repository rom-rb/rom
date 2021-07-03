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
        inflector = options.fetch(:inflector)

        class_name = "ROM::Relation[#{inflector.camelize(name)}]"

        gateway = options.fetch(:gateway, :default)
        adapter = options.fetch(:adapter)

        parent = ROM::Relation[adapter]

        Dry::Core::ClassBuilder.new(name: class_name, parent: parent).call do |klass|
          klass.gateway(gateway)
        end
      end
    end
  end
end
