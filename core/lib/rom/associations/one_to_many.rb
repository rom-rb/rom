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

      # @api protected
      def source_key
        source.schema.primary_key_name
      end

      # @api protected
      def target_key
        foreign_key
      end

      memoize :foreign_key
    end
  end
end
