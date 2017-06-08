require 'dry/core/cache'
require 'rom/mapper'
require 'rom/header_builder'

module ROM
  # @api private
  class MapperCompiler
    extend Dry::Core::Cache

    attr_reader :header_builder

    def initialize(options = EMPTY_HASH)
      @header_builder = HeaderBuilder.new(options)
    end

    def call(ast)
      fetch_or_store(ast) { Mapper.build(header_builder[ast]) }
    end
    alias_method :[], :call

    def with(options)
      self.class.new(options)
    end
  end
end
