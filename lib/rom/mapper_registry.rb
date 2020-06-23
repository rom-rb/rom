# frozen_string_literal: true

require "rom/struct"
require "rom/registry"
require "rom/mapper_compiler"

module ROM
  # @private
  class MapperRegistry < Registry
    # @api private
    def self.element_not_found_error
      MapperMissingError
    end

    # @!attribute [r] compiler
    #   @return [MapperCompiler] A mapper compiler instance
    option :compiler, default: lambda {
      MapperCompiler.new(EMPTY_HASH, cache: cache)
    }

    # @see Registry
    # @api public
    def [](*args)
      if args[0].is_a?(Symbol)
        super
      else
        cache.fetch_or_store(args.hash) { compiler.(*args) }
      end
    end
  end
end
