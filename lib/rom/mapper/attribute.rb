# encoding: utf-8

module ROM
  class Mapper

    # Represents a mapping attribute
    #
    # @private
    class Attribute
      include Adamantium, Concord::Public.new(:name, :options), Morpher::NodeHelpers

      # @api private
      def self.build(*args)
        input = args.first

        if input.kind_of?(self)
          input
        else
          name, options = args
          new(name, options || {})
        end
      end

      # @api private
      def to_ast
        options.fetch(:node) { s(:block, s(:key_fetch, name), s(:key_dump, name)) }
      end
      memoize :to_ast

      def key?
        options.fetch(:key, false)
      end
      memoize :key?

      # @api private
      def mapping
        { tuple_key => name }
      end
      memoize :mapping

      # @api private
      def tuple_key
        options[:from] || name
      end
      memoize :tuple_key

      def type
        options[:type] || Object
      end
      memoize :type

    end # Attribute

  end # Mapper
end # ROM
