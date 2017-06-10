require 'rom/initializer'
require 'rom/mapper'
require 'rom/header_builder'
require 'rom/struct'
require 'rom/cache'

module ROM
  # @api private
  class MapperCompiler
    extend Initializer

    option :cache, reader: true, default: -> { Cache.new }
    option :struct_namespace, reader: true, default: -> { ROM::Struct }

    attr_reader :header_builder

    def initialize(*args)
      super
      @header_builder = HeaderBuilder.new(
        struct_namespace: struct_namespace,
        cache: cache
      )
      @cache = cache.namespaced(:mappers) unless cache.namespaced?
    end

    def call(ast)
      cache.fetch_or_store(ast) { Mapper.build(header_builder[ast]) }
    end
    alias_method :[], :call

    def with(options)
      self.class.new(options)
    end
  end
end
