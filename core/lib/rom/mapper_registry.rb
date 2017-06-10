require 'rom/registry'
require 'rom/mapper_compiler'

module ROM
  # @private
  class MapperRegistry < Registry
    def self.element_not_found_error
      MapperMissingError
    end

    option :compiler, reader: true, default: -> { MapperCompiler.new }

    # @see Registry
    # @api public
    def [](*args)
      if args[0].is_a?(Symbol)
        super
      else
        cache.fetch_or_store(args.hash) { compiler.(*args) }
      end
    end

    # Get a new mapper registry configured with a specific struct namespace
    #
    # @return [MapperRegistry]
    #
    # @api private
    def struct_namespace(namespace)
      with(compiler: compiler.with(struct_namespace: namespace))
    end
  end
end
