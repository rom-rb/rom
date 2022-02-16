# frozen_string_literal: true

require "rom/core"
require "rom/plugins/class_methods"

require_relative "mapper/dsl"
require_relative "components/provider"

module ROM
  # Mapper is a simple object that uses transformers to load relations
  #
  # @private
  class Mapper
    extend ROM::Provider(type: :mapper)
    extend Plugins::ClassMethods

    include Dry::Equalizer(:transformers, :header)
    include DSL

    setting :inherit_header, default: true
    setting :reject_keys, default: false
    setting :prefix_separator, default: "_"
    setting :symbolize_keys
    setting :copy_keys
    setting :prefix

    # @return [Object] transformers object built by a processor
    #
    # @api private
    attr_reader :transformers

    # @return [Header] header that was used to build the transformers
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
      name = processor.name.split("::").last.downcase.to_sym
      processors.update(name => processor)
    end
    require "rom/processor/transformer"

    # Prepares an array of headers for a potentially multistep mapper
    #
    # @return [Array<Header>]
    #
    # @api private
    def self.headers(header)
      return [header] if steps.empty?
      return steps.map(&:header) if attributes.empty?

      raise(MapperMisconfiguredError, "cannot mix outer attributes and steps")
    end

    # Build a mapper using provided processor type
    #
    # @return [Mapper]
    #
    # @api private
    def self.build(header = self.header, processor = :transformer)
      new(header, processor)
    end

    # @api private
    def initialize(header, processor = :transformer)
      processor = Mapper.processors.fetch(processor)
      @transformers = self.class.headers(header).map do |hdr|
        processor.build(self, hdr)
      end
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
