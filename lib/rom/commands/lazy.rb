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

      attr_reader :command_proc

      # @api private
      def initialize(command, evaluator, command_proc = nil)
        @command = command
        @evaluator = evaluator
        @command_proc = command_proc || proc { |*| command }
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
          last.map.with_index do |parent, index|
            children = evaluator.call(first, index)

            if command.is_a?(Create)
              command_proc[command, parent, children].call(children, parent)
            elsif command.is_a?(Update)
              children.map do |child|
                command_proc[command, parent, child].call(child, parent)
              end
            end
          end.reduce(:concat)
        else
          input = evaluator.call(first)

          if command.is_a?(Create)
            command.call(input, *args[1..size-1])
          elsif command.is_a?(Update)
            if input.is_a?(Array)
              input.map.with_index do |item, index|
                command_proc[command, last, item].call(item, *args[1..size-1])
              end
            else
              command_proc[command, *(size > 1 ? [last, input] : [input])]
                .call(input, *args[1..size-1])
            end
          elsif command.is_a?(Delete)
            if input.is_a?(Array)
              input.map do |item|
                command_proc[command, *(size > 1 ? [last, item] : [input])].call
              end
            else
              command_proc[command, input].call
            end
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
            self.class.new(response, evaluator, command_proc)
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
