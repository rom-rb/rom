module DataMapper
  class Attribute

    # Provides coercion behavior for {Attribute} subclasses
    module Coercible

      # @api public
      def load(*)
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
