module ROM
  # Setup DSL-specific mapper extensions
  #
  # @private
  class Mapper
    # Generate a mapper subclass
    #
    # This is used by Setup#mappers DSL
    #
    # @api private
    def self.build_class(name, options = {}, &block)
      class_name = "ROM::Mapper[#{name}]"

      parent = options[:parent]
      inherit_header = options.fetch(:inherit_header) { Mapper.inherit_header }

      parent_class =
        if parent
          ROM.boot.mapper_classes.detect { |klass| klass.relation == parent }
        else
          self
        end

      ClassBuilder.new(name: class_name, parent: parent_class).call do |klass|
        klass.relation(name)
        klass.inherit_header(inherit_header)

        klass.class_eval(&block) if block
      end
    end
  end
end
