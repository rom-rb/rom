# frozen_string_literal: true

module ROM
  module Registries
    module Nestable
      # @api public
      def fetch(key, &block)
        if relation_namespace?(key)
          super(namespace, &block)
        elsif relation_scope_key?(key)
          scoped(key)
        else
          super(key, &block)
        end
      end
      alias_method :[], :fetch

      private

      # @api private
      def relation_namespace?(key)
        # TODO: stop nesting canonical mappers under relation's id ie `mappers.users.users`
        path.last == key && !mappers?
      end

      # @api private
      def relation_scope_key?(key)
        !key?(key) && relation_ids.include?(key)
      end
    end
  end
end
