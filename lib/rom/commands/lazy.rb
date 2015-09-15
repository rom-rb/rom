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

      attr_reader :options

      # @api private
      def initialize(command, evaluator, options = {})
        @command = command
        @evaluator = evaluator
        @options = options
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

            if command.is_a?(Create)
              command.call(input, item)
            else
              raise NotImplementedError
            end
          end.reduce(:concat)
        else
          input = evaluator.call(first)

          if command.is_a?(Create)
            command.call(input, *args[1..size-1])
          elsif command.is_a?(Update)
            if view
              if input.is_a?(Array)
                input.map.with_index do |item, index|
                  restricted_command = command.public_send(view, *view_args(first, index))
                  restricted_command.call(item, *args[1..size-1])
                end
              else
                restricted_command = command.public_send(view, *view_args(first))
                restricted_command.call(input, *args[1..size-1])
              end
            else
              command.call(input, *args[1..size-1])
            end
          elsif command.is_a?(Delete)
            if input.is_a?(Array)
              input.map.with_index do |item, index|
                command.public_send(view, *view_args(first, index)).call
              end
            else
              raise NotImplementedError
            end
          end
        end
      end

      def view
        options[0]
      end

      def view_args(input, index = nil)
        options[1].map do |path|
          path.split('.').map(&:to_sym).reduce(input) do |a,e|
            if a.is_a?(Array)
              a[index][e]
            else
              a.fetch(e)
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
