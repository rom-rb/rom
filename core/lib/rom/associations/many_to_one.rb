require 'rom/associations/abstract'

module ROM
  module Associations
    class ManyToOne < Abstract
      # @api public
      def call(left = self.target)
        raise NotImplementedError
      end

      # @api private
      def associate(child, parent)
        fk, pk = join_key_map
        child.merge(fk => parent.fetch(pk))
      end

      protected

      # @api private
      def with_keys(&block)
        source_key = foreign_key || source.foreign_key(target.name.dataset)
        target_key = target.schema.primary_key_name
        return [source_key, target_key] unless block
        yield(source_key, target_key)
      end
    end
  end
end
