# frozen_string_literal: true

require "rom/pipeline"

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

        if response.nil? || (many? && response.empty?)
          return one? ? nil : EMPTY_ARRAY
        end

        if one? && !graph?
          if right.is_a?(Command) || right.is_a?(Commands::Composite)
            right.call([response].first)
          else
            right.call([response]).first
          end
        elsif one? && graph?
          right.call(response).first
        else
          right.call(response)
        end
      end
      alias_method :[], :call

      # @api private
      def graph?
        left.is_a?(Graph)
      end

      # @api private
      def result
        left.result
      end

      # @api private
      def decorate?(response)
        super || response.is_a?(Graph)
      end
    end
  end
end
