require 'rom/mapper/dsl'

module ROM
  # Mapper is a simple object that uses transformers to load relations
  #
  # @private
  class Mapper
    include DSL
    include Equalizer.new(:transformers, :header)

    defines :relation, :register_as, :symbolize_keys,
      :prefix, :prefix_separator, :inherit_header, :reject_keys

    inherit_header true
    reject_keys false
    prefix_separator '_'.freeze

    # @return [Object] transformers object built by a processor
    #
    # @api private
    attr_reader :transformers

    # @return [Header] header that was used to build the transformers
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
      if steps.empty?
        new(Mapper.processors.fetch(processor).build(header), header)
      else

        step_transformers = steps.map do |s|
          new(Mapper.processors.fetch(processor).build(s.header), s.header).transformers.first
        end

        new(step_transformers, header)
      end
    end

    # @api private
    def self.registry(descendants)
      descendants.each_with_object({}) do |klass, h|
        name = klass.register_as || klass.relation
        (h[klass.base_relation] ||= {})[name] = klass.build
      end
    end

    # @api private
    def initialize(transformers, header)
      @transformers = Array(transformers)
      @header = header
    end

    # @return [Class] optional model that is instantiated by a mapper
    #
    # @api private
    def model
      header.model
    end

    # Process a relation using the transformers
    #
    # @api private
    def call(relation)
      transformers.reduce(relation.to_a) { |a, e| e.call(a) }
    end
  end
end
