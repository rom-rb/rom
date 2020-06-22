# frozen_string_literal: true

module ROM
  # ROM's open structs are used for relations with empty schemas.
  # Such relations may exist in cases like using raw SQL strings
  # where schema was not explicitly defined using `view` DSL.
  #
  # @api public
  class OpenStruct
    IVAR = -> v { :"@#{v}" }

    # @api private
    def initialize(attributes)
      attributes.each do |key, value|
        instance_variable_set(IVAR[key], value)
      end
    end

    # @api private
    def respond_to_missing?(meth, include_private = false)
      super || instance_variables.include?(IVAR[meth])
    end

    private

    # @api private
    def method_missing(meth, *args, &block)
      ivar = IVAR[meth]

      if instance_variables.include?(ivar)
        instance_variable_get(ivar)
      else
        super
      end
    end
  end
end
