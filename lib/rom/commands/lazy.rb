# frozen_string_literal: true

require 'rom/commands/composite'
require 'rom/commands/graph'

module ROM
  module Commands
    # Lazy command wraps another command and evaluates its input when called
    #
    # @api private
    class Lazy
      include Dry::Equalizer(:command, :evaluator)

      # @attr_reader [Command] command The wrapped command
      attr_reader :command

      alias_method :unwrap, :command

      # @attr_reader [Proc] evaluator The proc that will evaluate the input
      attr_reader :evaluator

      attr_reader :command_proc

      # @api private
      def self.[](command)
        case command
        when Commands::Create then Lazy::Create
        when Commands::Update then Lazy::Update
        when Commands::Delete then Lazy::Delete
        else
          self
        end
      end

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
      def call(*_args)
        raise NotImplementedError
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

      # Combine with other lazy commands
      #
      # @see Abstract#combine
      #
      # @return [Graph]
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
      ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
    end
  end
end

require 'rom/commands/lazy/create'
require 'rom/commands/lazy/update'
require 'rom/commands/lazy/delete'
