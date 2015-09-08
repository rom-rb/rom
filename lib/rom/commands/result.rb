module ROM
  module Commands
    # Abstract result class for success and error results
    #
    # @api public
    class Result
      # Return command execution result
      #
      # @api public
      attr_reader :value

      # Return potential command execution result error
      #
      # @api public
      attr_reader :error

      # Coerce result to an array
      #
      # @abstract
      #
      # @api public
      def to_ary
        raise NotImplementedError
      end
      alias_method :to_a, :to_ary

      # Return true if command successful
      #
      # @api public
      def success?
        is_a?(Success)
      end

      # Return true if command failed
      #
      # @api public
      def failure?
        is_a?(Failure)
      end

      # Success result has a value and no error
      #
      # @api public
      class Success < Result
        # @api private
        def initialize(value)
          @value = value.is_a?(self.class) ? value.value : value
        end

        # Call next command on continuation
        #
        # @api public
        def >(other)
          other.call(value)
        end

        # Return the value
        #
        # @return [Array]
        #
        # @api public
        def to_ary
          value.to_ary
        end
      end

      # Failure result has an error and no value
      #
      # @api public
      class Failure < Result
        # @api private
        def initialize(error)
          @error = error
        end

        # Do not call next command on continuation
        #
        # @return [self]
        #
        # @api public
        def >(_other)
          self
        end

        # Return the error
        #
        # @return [Array<CommandError>]
        #
        # @api public
        def to_ary
          error
        end
      end
    end
  end
end
