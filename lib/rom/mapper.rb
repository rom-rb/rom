require 'rom/mapper/dsl'

module ROM
  # Mapper is a simple object that uses a transformer to load relations
  #
  # @private
  class Mapper
    include DSL
    include Equalizer.new(:transformer, :header)

    defines :relation, :register_as, :symbolize_keys,
      :prefix, :prefix_separator, :inherit_header

    inherit_header true
    prefix_separator '_'.freeze

    # @return [Object] transformer object built by a processor
    #
    # @api private
    attr_reader :transformer

    # @return [Header] header that was used to build the transformer
    #
    # @api private
    attr_reader :header

    # Register suclasses during setup phase
    #
    # @api private
    def self.inherited(klass)
      super
      ROM.register_mapper(klass)
    end

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
    def self.registry(descendants)
      descendants.each_with_object({}) do |klass, h|
        name = klass.register_as || klass.relation
        (h[klass.base_relation] ||= {})[name] = klass.build
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
    def call(relation)
      transformer[relation.to_a]
    end
  end
end
