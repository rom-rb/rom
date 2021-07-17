# frozen_string_literal: true

require "dry/core/memoizable"
require "dry/effects"

require "rom/constants"
require "rom/cache"
require "rom/command_compiler"
require "rom/mapper_compiler"

module ROM
  # @api private
  class Inferrer
    include Dry::Core::Memoizable
    include Dry::Effects::Reader(:resolver)

    attr_reader :cache, :config

    # @api private
    def initialize
      @cache = Cache.new
    end

    # @api private
    def call(ast, type, **opts)
      compiler(type, **opts).then do |compiler|
        case type
        when :mappers
          compiler.(ast)
        when :commands
          compiler.(*ast) # TODO: unify this
        end
      end
    end

    # @api private
    memoize def compiler(type, adapter:)
      case type
      when :mappers
        # TODO: move this to config
        adapter_ns = ROM.adapters[adapter] || ROM

        klass = adapter_ns.const_defined?(:MapperCompiler) ?
          adapter_ns::MapperCompiler : MapperCompiler

        klass.new(cache: cache)
      when :commands
        CommandCompiler.new(cache: cache.namespaced(:commands), resolver: resolver)
      end
    end
  end
end
