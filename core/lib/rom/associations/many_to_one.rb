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

      # @api protected
      def source_key
        foreign_key
      end

      # @api protected
      def target_key
        target.schema.primary_key_name
      end

      memoize :foreign_key
    end
  end
end
