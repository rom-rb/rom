module Rom
  module Relation
    class Header

      # An attribute in the {Relation::Header}
      class Attribute < Struct.new(:field, :prefix, :aliased)

        CACHE = {}

        # Build and cache a new {Attribute} instance
        #
        # @param [#to_sym] field
        #   the attribute's field name
        #
        # @param [#to_sym] prefix
        #   the prefix to use for aliasing
        #
        # @param [Boolean] aliased
        #   true if this attribute is aliased, false otherwise
        #
        # @return [Attribute]
        #
        # @api private
        def self.build(field, prefix, aliased = false)
          key = "#{field}-#{prefix}-#{aliased}"
          CACHE.fetch(key) {
            CACHE[key] = Attribute.new(field, prefix, aliased)
          }
        end

        # Return this attribute's name
        #
        # @return [Symbol]
        #
        # @api private
        attr_reader :name

        private :field=, :prefix=, :aliased=

        # Initialize a new instance
        #
        # @param [#to_sym] field
        #   the attribute's field name
        #
        # @param [#to_sym] prefix
        #   the prefix to use for aliasing
        #
        # @param [Boolean] aliased
        #   true if this attribute is aliased, false otherwise
        #
        # @return [undefined
        #
        # @api private
        def initialize(field, prefix, aliased)
          super
          @name = aliased ? :"#{prefix}_#{field}" : field.to_sym
        end

      end # struct Attribute

    end # class Header
  end # module Relation
end # module Rom
