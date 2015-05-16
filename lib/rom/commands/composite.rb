module ROM
  module Commands
    # Composite command that consists of left and right commands
    #
    # @api public
    class Composite < Pipeline::Composite
      # Calls the composite command
      #
      # Right command is called with a result from the left one
      #
      # @return [Object]
      #
      # @api public
      def call(*args)
        response = left.call(*args)

        if result == :one
          if right.is_a?(Command) || right.is_a?(Commands::Composite)
            right.call([response].first)
          else
            right.call([response]).first
          end
        else
          right.call(response)
        end
      end
      alias_method :[], :call

      # @api private
      def result
        left.result
      end
    end
  end
end
