require 'concurrent/map'

require 'rom/registry'
require 'rom/mapper_compiler'

module ROM
  # @private
  class MapperRegistry < Registry
    def self.element_not_found_error
      MapperMissingError
    end

    attr_reader :compiler

    attr_reader :__cache__

    def initialize(elements = EMPTY_HASH, compiler = MapperCompiler.new)
      super
      @compiler = compiler
      @__cache__ = Concurrent::Map.new
    end

    # @see Registry
    # @api public
    def [](*args)
      if args[0].is_a?(Symbol)
        super
      else
        fetch_or_store(*args) { compiler.(*args) }
      end
    end

    # Get a new mapper registry configured with a specific struct namespace
    #
    # @return [MapperRegistry]
    #
    # @api private
    def struct_namespace(namespace)
      self.class.new(elements, compiler.with(struct_namespace: namespace))
    end

    private

    # @api private
    def fetch_or_store(*args, &block)
      __cache__.fetch_or_store(args.hash, &block)
    end
  end
end
