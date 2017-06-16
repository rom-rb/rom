require 'rom/associations/abstract'

module ROM
  module Associations
    class OneToMany < Abstract
      # @api public
      def call(right = self.target)
        raise NotImplementedError
      end

      # @api public
      def join_keys
        with_keys { |source_key, target_key|
          { source[source_key].qualified(source_alias) => target[target_key].qualified }
        }
      end

      # @api private
      def associate(child, parent)
        pk, fk = join_key_map
        child.merge(fk => parent.fetch(pk))
      end

      protected

      # @api private
      def with_keys(&block)
        source_key = source.schema.primary_key_name
        target_key = foreign_key || target.foreign_key(source.name)
        return [source_key, target_key] unless block
        yield(source_key, target_key)
      end
    end
  end
end
