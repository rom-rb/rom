# encoding: utf-8

module ROM
  class Mapper

    # Represents a mapping attribute
    #
    # @private
    class Attribute
      include Adamantium, Concord::Public.new(:name, :options), Morpher::NodeHelpers

      class EmbeddedValue < Attribute

        # @api private
        def to_ast
          s(:key_transform, name, name, node)
        end
        memoize :to_ast

        # @api private
        def header
          options.fetch(:header)
        end
        memoize :header

        private

        # @api private
        def node
          options.fetch(:node)
        end
        memoize :node
      end

      class EmbeddedCollection < Attribute

        # @api private
        def to_ast
          s(:key_transform, name, name, s(:map, node))
        end
        memoize :to_ast

        # @api private
        def header
          options.fetch(:header)
        end
        memoize :header

        private

        # @api private
        def node
          options.fetch(:node)
        end
        memoize :node
      end

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
        options.fetch(:node) { s(:block, s(:key_fetch, tuple_key), s(:key_dump, name)) }
      end
      memoize :to_ast

      # @api private
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

      # @api private
      def type
        options[:type] || Object
      end
      memoize :type

      # @api private
      def rename(new_name)
        self.class.new(new_name, options)
      end

    end # Attribute

  end # Mapper
end # ROM
