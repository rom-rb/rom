# frozen_string_literal: true

module ROM
  module Registries
    # @api public
    class Associations < Root
      # @api public
      def fetch(key, &block)
        super(key) {
          components.key?(key) ? super(key, &block) : fetch_aliased_association(key)
        }
      end
      alias_method :[], :fetch

      private

      # @api private
      def fetch_aliased_association(key)
        components
          .associations(namespace: namespace)
          .detect { |assoc| key == "#{namespace}.#{assoc.config.name}" }
          .then { |assoc| fetch(assoc.config.as) if assoc }
      end
    end
  end
end
