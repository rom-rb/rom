require 'rom/associations/abstract'

module ROM
  module Associations
    class ManyToOne < Abstract
      # @api public
      def call(*)
        raise NotImplementedError
      end

      # @api public
      def foreign_key
        definition.foreign_key || source.foreign_key(target.name)
      end

      # @api private
      def associate(child, parent)
        fk, pk = join_key_map
        child.merge(fk => parent.fetch(pk))
      end

      protected

      # @api private
      def with_keys(&block)
        source_key = foreign_key
        target_key = target.schema.primary_key_name
        return [source_key, target_key] unless block
        yield(source_key, target_key)
      end

      memoize :foreign_key
    end
  end
end
