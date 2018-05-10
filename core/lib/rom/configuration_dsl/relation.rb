require 'dry/core/class_builder'

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
        class_name = "ROM::Relation[#{ROM.inflector.camelize(name)}]"
        adapter = options.fetch(:adapter)

        Dry::Core::ClassBuilder.new(name: class_name, parent: ROM::Relation[adapter]).call do |klass|
          klass.gateway(options.fetch(:gateway, :default))
          klass.schema(name) { }
        end
      end
    end
  end
end
