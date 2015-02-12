module ROM
  module Commands
    # Abstract result class for success and error results
    #
    # @public
    class Result
      # Wrap the value in a ROM::Commands::Success
      #
      # @api public
      def self.success(value)
        Success.new(value)
      end

      # Wrap the error in a ROM::Commands::Failure
      #
      # @api public
      def self.failure(error)
        Failure.new(error)
      end

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

      # Success result has a value and no error
      #
      # @public
      class Success < Result
        include Equalizer.new(:class, :value)

        # @api private
        def initialize(value)
          @value = value.is_a?(self.class) ? value.value : value
        end

        # Call next command on continuation
        #
        # @api public
        def >(other)
          other.call(value, Result)
        end

        # Yield to block with value of result
        #
        # @api public
        def and_then(&blk)
          self > blk
        end

        # Ignore block and return self
        #
        # @return [self]
        #
        # @api public
        def or_else(&_)
          self
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
      # @public
      class Failure < Result
        include Equalizer.new(:class, :error)

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

        # Do not yield to block, return self
        #
        # @return [self]
        #
        # @api public
        def and_then(&blk)
          self > blk
        end

        # Yield to block with error of result
        #
        # @api public
        def or_else(&blk)
          blk.call(error, Result)
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
