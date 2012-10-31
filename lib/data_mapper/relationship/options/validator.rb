module DataMapper
  class Relationship
    class Options

      # Abstract validator class for relationship options
      #
      class Validator
        InvalidOptionException = Class.new(StandardError)

        # Initializes a validator instance
        #
        # @param [Hash] options
        #
        # @return [undefined]
        #
        # @api private
        def initialize(options)
          @options = options
        end

        # Validates relationship options
        #
        # @return [undefined]
        #
        # @raise [InvalidOptionException]
        #
        # @abstract
        #
        # @api private
        def validate
          # TODO implement (in subclasses)
        end

      end # class Validator

    end # class Options
  end # class Relationship
end # module DataMapper
