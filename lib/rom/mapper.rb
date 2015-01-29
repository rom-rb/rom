require 'rom/mapper/dsl'

module ROM
  # Mapper is a simple object that uses a transformer to load relations
  #
  # @private
  class Mapper
    extend DescendantsTracker
    include DSL
    include Equalizer.new(:transformer, :header)

    defines :relation, :symbolize_keys, :prefix, :inherit_header

    inherit_header true

    # @return [Object] transformer object built by a processor
    #
    # @api private
    attr_reader :transformer

    # @return [Header] header that was used to build the transformer
    #
    # @api private
    attr_reader :header

    # @return [Hash] registered processors
    #
    # @api private
    def self.processors
      @_processors ||= {}
    end

    # Register a processor class
    #
    # @return [Hash]
    #
    # @api private
    def self.register_processor(processor)
      name = processor.name.split('::').last.downcase.to_sym
      processors.update(name => processor)
    end

    # Build a mapper using provided processor type
    #
    # @return [Mapper]
    #
    # @api private
    def self.build(header = self.header, processor = :transproc)
      new(Mapper.processors.fetch(processor).build(header), header)
    end

    # @api private
    def self.build_class(name, options = {}, &block)
      class_name = "ROM::Mapper[#{name}]"

      parent = options[:parent]
      inherit_header = options.fetch(:inherit_header) { Mapper.inherit_header }

      parent_class =
        if parent
          descendants.detect { |klass| klass.relation == parent }
        else
          self
        end

      ClassBuilder.new(name: class_name, parent: parent_class).call do |klass|
        klass.relation(name)
        klass.inherit_header(inherit_header)

        klass.class_eval(&block) if block
      end
    end

    # @api private
    def self.registry
      Mapper.descendants.each_with_object({}) do |klass, h|
        (h[klass.base_relation] ||= {})[klass.relation] = klass.build
      end
    end

    # @api private
    def initialize(transformer, header)
      @transformer = transformer
      @header = header
    end

    # @return [Class] optional model that is instantiated by a mapper
    #
    # @api private
    def model
      header.model
    end

    # Process a relation using the transformer
    #
    # @api private
    def process(relation, &block)
      transformer[relation.to_a].each(&block)
    end
  end
end
