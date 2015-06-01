require 'rom/pipeline'
require 'rom/commands/graph/class_interface'

module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      extend ClassInterface

      include Pipeline
      include Pipeline::Proxy

      # @attr_reader [Command] root The root command
      attr_reader :root

      # @attr_reader [Array<Command>] nodes The child commands
      attr_reader :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # Calls root and all nodes with the result from root
      #
      # Graph results are mappable through `combine` operation in mapper DSL
      #
      # @example
      #   create_user = rom.command(:users).create
      #   create_task = rom.command(:tasks).create
      #
      #   command = create_user
      #     .with(name: 'Jane')
      #     .combine(create_task.with(title: 'Task'))
      #
      #   command.call
      #
      # @return [Array] nested array with command results
      #
      # @api public
      def call(*args)
        left = root.call(*args)

        right = nodes.map do |node|
          if node.lazy?
            node.call(args.first, left)
          else
            node.call(left)
          end
        end

        if result.equal?(:one)
          [[left], right]
        else
          [left, right]
        end
      end
    end
  end
end
