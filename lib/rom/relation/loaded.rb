require 'rom/support/array_dataset'

module ROM
  class Relation
    # Wraps loaded data from a relation and gives access to its mappers
    #
    # @public
    class Loaded
      include ArrayDataset

      forward :first

      # @return [ROM::MapperRegistry]
      #
      # @api private
      attr_reader :mappers

      # @api private
      def initialize(data, mappers)
        super
        @mappers = mappers
      end

      # Map loaded relation using a specified mapper
      #
      # @example
      #
      #   loaded = rom.relation(:users) { |r| r.by_name('Jane') }
      #
      #   # mapping with a single mapper
      #   loaded.map_with(:entity_mapper)
      #
      #   # mapping with a multiple mappers
      #   loaded.map_with(:entity_mapper, :presenter_decorator)
      #
      # @return [Array] array of mapped tuples
      #
      # @api public
      def map_with(*names)
        result = data
        names.each { |name| result = mappers[name].call(result) }
        result
      end
    end
  end
end
