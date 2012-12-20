module DataMapper
  class Attribute

    module Coercible

      # @api public
      def load(tuple)
        value = super
        Virtus::Coercion[value.class].send(coercion_method, value)
      end

      # @api private
      def coercion_method
        options[:coercion_method]
      end

    end

  end # class Attribute
end # module DataMapper
