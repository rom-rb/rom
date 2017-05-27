require 'dry/core/cache'
require 'rom/mapper'
require 'rom/repository/header_builder'

module ROM
  class Repository
    # @api private
    class MapperBuilder
      extend Dry::Core::Cache

      attr_reader :header_builder

      def initialize(options = EMPTY_HASH)
        @header_builder = HeaderBuilder.new(options)
      end

      def call(ast)
        fetch_or_store(ast) { Mapper.build(header_builder[ast]) }
      end
      alias_method :[], :call
    end
  end
end
