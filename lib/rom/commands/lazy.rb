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
        first = args.first
        last = args.last
        size = args.size

        if size > 1 && last.is_a?(Array)
          last.map.with_index do |item, index|
            input = evaluator.call(first, index)
            command.call(input, item)
          end.reduce(:concat)
        else
          input = evaluator.call(first)
          command.call(input, *args[1..size-1])
        end
      rescue => err
        raise CommandFailure.new(command, err)
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
