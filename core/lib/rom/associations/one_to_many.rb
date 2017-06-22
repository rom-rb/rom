require 'rom/associations/abstract'

module ROM
  module Associations
    class OneToMany < Abstract
      # @api public
      def call(*)
        raise NotImplementedError
      end

      # @api public
      def foreign_key
        definition.foreign_key || target.foreign_key(source.name)
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
        target_key = foreign_key
        return [source_key, target_key] unless block
        yield(source_key, target_key)
      end
    end
  end
end
