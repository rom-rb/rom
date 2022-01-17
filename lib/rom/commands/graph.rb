# frozen_string_literal: true

require "rom/initializer"
require "rom/pipeline"
require "rom/commands/graph/class_interface"

module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      extend Initializer
      include Dry::Equalizer(:root, :nodes)

      extend ClassInterface

      include Pipeline
      include Pipeline::Proxy

      # @attr_reader [Command] root The root command
      param :root

      # @attr_reader [Array<Command>] nodes The child commands
      param :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @attr_reader [Symbol] root's relation name
      option :name, default: -> { root.name }

      # Calls root and all nodes with the result from root
      #
      # Graph results are mappable through `combine` operation in mapper DSL
      #
      # @example
      #   create_user = rom.commands[:users][:create]
      #   create_task = rom.commands[:tasks][:create]
      #
      #   command = create_user
      #     .curry(name: 'Jane')
      #     .combine(create_task.curry(title: 'Task'))
      #
      #   command.call
      #
      # @return [Array] nested array with command results
      #
      # @api public
      def call(*args)
        left = root.call(*args)

        right = nodes.map { |node|
          response =
            if node.lazy?
              node.call(args.first, left)
            else
              node.call(left)
            end

          if node.one? && !node.graph?
            [response]
          else
            response
          end
        }

        if one?
          [[left], right]
        else
          [left, right]
        end
      end

      # @api private
      def graph?
        true
      end

      private

      # @api public
      def composite_class
        Command::Composite
      end
    end
  end
end
