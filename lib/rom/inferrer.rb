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
    include Dry::Effects::Reader(:registry)

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
          compiler(type, **opts).call(ast)
        when :commands
          compiler(type, **opts).call(*ast)
        end
      end
    end

    # @api private
    memoize def compiler(type, adapter:)
      case type
      when :mappers
        if ROM.adapters[adapter].const_defined?(:MapperCompiler)
          ROM.adapters[adapter]::MapperCompiler
        else
          MapperCompiler
        end.new(cache: cache)
      when :commands
        CommandCompiler.new(cache: cache.namespaced(:commands), registry: registry)
      end
    end
  end
end
