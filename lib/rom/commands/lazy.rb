require 'rom/commands/composite'
require 'rom/commands/graph'

module ROM
  module Commands
    # Lazy command wraps another command and evaluates its input when called
    #
    # @api private
    class Lazy
      # @attr_reader [Command] command The wrapped command
      attr_reader :command

      # @attr_reader [Proc] evaluator The proc that will evaluate the input
      attr_reader :evaluator

      # @api private
      def initialize(command, evaluator)
        @command = command
        @evaluator = evaluator
      end

      # Evaluate command's input using the input proc and pass to command
      #
      # @return [Array,Hash]
      #
      # @api public
      def call(*args)
        if args.size > 1 && args.last.is_a?(Array)
          results = []

          args.last.each_with_index do |item, index|
            input = evaluator[args.first, index]
            other = args[2..args.size]

            results.concat(command.call(input, item, *other))
          end

          results
        else
          input = evaluator[args.first]
          other = args[1..args.size]

          if result.equal?(:many)
            command.call(input, *other)
          else
            command.call(*([input] + other))
          end
        end
      end

      # Compose a lazy command with another one
      #
      # @see Commands::Abstract#>>
      #
      # @return [Composite]
      #
      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # @see Abstract#combine
      #
      # @api public
      def combine(*others)
        Graph.new(self, others)
      end

      # @api private
      def lazy?
        true
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        super || command.respond_to?(name)
      end

      private

      # @api private
      def method_missing(name, *args, &block)
        if command.respond_to?(name)
          response = command.public_send(name, *args, &block)

          if response.instance_of?(command.class)
            self.class.new(response, evaluator)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
