# frozen_string_literal: true

module ROM
  class Mapper
    # Setup DSL-specific mapper extensions
    #
    # @private
    class Builder
      # Generate a mapper subclass
      #
      # This is used by Setup#mappers DSL
      #
      # @api private
      def self.build_class(name, mapper_registry, options = EMPTY_HASH, &block)
        class_name = "ROM::Mapper[#{name}]"

        parent = options[:parent]
        inherit_header = options.fetch(:inherit_header) { ROM::Mapper.inherit_header }

        parent_class =
          if parent
            mapper_registry.detect { |klass| klass.relation == parent }
          else
            ROM::Mapper
          end

        Dry::Core::ClassBuilder.new(name: class_name, parent: parent_class).call do |klass|
          klass.register_as(name)
          klass.relation(name)
          klass.inherit_header(inherit_header)

          klass.class_eval(&block) if block
        end
      end
    end
  end
end
